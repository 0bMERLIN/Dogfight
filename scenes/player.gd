# player.gd
extends CharacterBody3D

@export var rot_acc = Vector3(0.015, 0.015, 0.04)
@export var max_rot_vel = Vector3(0.015, 0.015, 0.03)
@export var turn_camera_mode = false;
@export var radar : PackedScene
@export var hp_scene : PackedScene

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
	
	$Hud/Hp.text = str(hitpoints)
	
	if hitpoints <= 0:
		$Overlays/EnemyMarker.hide()
		if multiplayer.is_server():
			position = Vector3(0, 0, 0)
			hitpoints = 100
	
	if(input.firering):
		if not multiplayer.is_server():
			return
		shoot()
	
	if(input.missile):
		if not multiplayer.is_server():
			return
		missile()

func shoot():
	var b = Bullet.instantiate()
	BulletsCollection.add_child(b, true)
	b.transform = $BulletMuzzle.global_transform

func missile():
	var m = Missile.instantiate()
	m.target = PlayerCollection.get_node($Input.Target)
	BulletsCollection.add_child(m, true)
	m.transform = $BulletMuzzle.global_transform

func hit(dmg):
	hitpoints -= dmg
