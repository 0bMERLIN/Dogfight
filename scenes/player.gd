# player.gd
extends CharacterBody3D

@export var rot_acc = Vector3(0.02, 0.02, 0.04)
@export var max_rot_vel = Vector3(0.025, 0.025, 0.03)
@export var turn_camera_mode = false;
@export var radar : PackedScene
@export var hp_scene : PackedScene

@export var kills = 0

var rot_vel = Vector3()

const lockOnRange = 30
const lockOnTime = 2.0
var lockOnTimer

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$Input.set_multiplayer_authority(id)

# Player synchronized input.
@onready var input = $Input

@export var BulletsCollection : Node
@export var Bullet : PackedScene
@export var Missile : PackedScene
@export var PlayerCollection: Node

var Ship_config : ConfigFile
@export var hitpoints = 100

var dead = false

func _ready():
	var rootNode = get_tree().root.get_child(0)
	Ship_config = rootNode.player_ship_info_CFG[player]
	
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		$CamRoot/Camera.current = true
		var radar_scene = radar.instantiate()
		radar_scene.players_scene = get_tree().get_root().get_node("Game/World/World/Players")
		radar_scene.main_player = self
		$Hud/RadarViewport.add_child(radar_scene)
		var hp_scene = hp_scene.instantiate()
		hp_scene.player = self
		$Hud/HpViewport.add_child(hp_scene)
	else:
		$Hud.hide()
	
	var s = load(Ship_config.get_value(Ship_config.get_value("", "current_ship_name"), "ship_scene")).instantiate()
	s.ship_config = Ship_config
	s.editing = false
	add_child(s)
	rotation = Vector3(0, PI, 0)
	$Overlays/EnemyMarker.hide()
	
	# Only process on server.
	# EDIT: Let the client simulate player movement too to compesate network input latency.
	# set_physics_process(multiplayer.is_server())


func _physics_process(delta):
	if !dead:
		var target_rot_vel = $Input.input_dir*max_rot_vel
		
		rot_vel.x += -rot_vel.x if target_rot_vel.x == 0 && abs(rot_vel.x) < 0.0002 else sign(target_rot_vel.x-rot_vel.x)*rot_acc.x*delta
		rot_vel.y += -rot_vel.y if target_rot_vel.y == 0 && abs(rot_vel.y) < 0.0003 else sign(target_rot_vel.y-rot_vel.y)*rot_acc.y*delta
		rot_vel.z += -rot_vel.z if target_rot_vel.z == 0 && abs(rot_vel.z) < 0.0003 else sign(target_rot_vel.z-rot_vel.z)*rot_acc.z*delta
		
		
		rotate(transform.basis.x.normalized(), rot_vel.x)
		rotate(transform.basis.y.normalized(), rot_vel.y)
		rotate(transform.basis.z.normalized(), rot_vel.z)
		if turn_camera_mode:
			if Input.is_action_pressed("game_c"):
				$CamRoot.rotation.y=PI
			else:
				$CamRoot.rotation.y=0
		else:	
			if Input.is_action_just_pressed("game_c"):
				$CamRoot.rotation.y=PI if $CamRoot.rotation.y == 0 else 0
				
		global_translate(transform.basis.z*delta*$Input.speed)
		
		
		$Hud/TargetRect.hide()
		$Hud/PreTargetRect.hide()
		if $CamRoot/Camera.current:
			$Hud/Kills.text = "Kills: " + str(kills)
			var closestTarget = null
			var closestTargetDist = INF
			for target in get_parent().get_children():
				if target != self:
					if !$CamRoot/Camera.is_position_behind(target.global_position):
						var targetCamPos = $CamRoot/Camera.unproject_position(target.global_position)
						target.get_node("Overlays/EnemyMarker").show()
						target.get_node("Overlays/EnemyMarker").position = targetCamPos - Vector2(7, 7)
						
						var targetDist = ($Hud/Hud.position - targetCamPos).length()
						if targetDist < closestTargetDist:
							closestTargetDist = targetDist
							closestTarget = target
						if target.name == $Input.Target:
							$Hud/TargetRect.show()
							$Hud/TargetRect.modulate.a = 1
							$Hud/TargetRect.position = $CamRoot/Camera.unproject_position(target.global_position) - Vector2(0, 16)
						
			if closestTarget != null:
				if closestTargetDist < lockOnRange:
					lockOnTimer += delta
					$Hud/PreTargetRect.show()
					$Hud/PreTargetRect.modulate.a = lockOnTimer/lockOnTime
					$Hud/PreTargetRect.position = $CamRoot/Camera.unproject_position(closestTarget.global_position) - Vector2(0, 16)
					if lockOnTimer >= lockOnTime:
						$Input.Target = closestTarget.name
				else:
					lockOnTimer = 0
		
		if hitpoints <= 0:
			dead = true
			$DemoShip.hide()
			$Overlays/EnemyMarker.hide()
			if $CamRoot/Camera.current:
				$Respawn.start()
				$Hud/Respawn.show()
			if multiplayer.is_server():
				$Respawn.start()
		
		if(input.firering):
			if not multiplayer.is_server():
				return
			shoot()
		
		if(input.missile):
			$Input.missile = false
			if not multiplayer.is_server():
				return
			
			missile()
	else:
		$Hud/Respawn.text = str(round($Respawn.time_left))

func shoot():
	var b = Bullet.instantiate()
	b.fired_by = self
	BulletsCollection.add_child(b, true)
	b.transform = $BulletMuzzle.global_transform

func missile():
	var m = Missile.instantiate()
	m.fired_by = self
	m.target = PlayerCollection.get_node($Input.Target)
	BulletsCollection.add_child(m, true)
	m.transform = $BulletMuzzle.global_transform

func hit(dmg):
	hitpoints -= dmg
	if hitpoints<=0 && !dead:
		return true
	return false


func _on_respawn_timeout():
	$Hud/Respawn.hide()
	if multiplayer.is_server():
		var pos := Vector2.from_angle(randf() * 2 * PI)
		position = Vector3(pos.x * 3000 * randf(), 0, pos.y * 3000 * randf())
		hitpoints = 100
	dead = false
	$DemoShip.show()
