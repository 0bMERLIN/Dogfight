# player.gd
extends CharacterBody3D

@export var rot_acc = Vector3(0.01, 0.01, 0.04)
@export var max_rot_vel = Vector3(0.015, 0.015, 0.03)
@export var turn_camera_mode=false;

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

func _ready():
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		$CamRoot/Camera.current = true
	rotation = Vector3(0, PI, 0)
	$Hud/EnemyMarker.hide()
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
	if $CamRoot/Camera.current:
		for target in get_parent().get_children():
			if target != self:
				var closestTarget = null
				var closestTargetDist = INF
				if !$CamRoot/Camera.is_position_behind(target.global_position):
					var targetCamPos = $CamRoot/Camera.unproject_position(target.global_position)
					target.get_node("Hud/EnemyMarker").show()
					target.get_node("Hud/EnemyMarker").position = targetCamPos - Vector2(7, 7)
					
					var targetDist = ($Hud/Hud/Control/Crosshair.position - targetCamPos).length()
					
					if targetDist < lockOnRange:
						lockOnTimer += delta
						if lockOnTimer >= lockOnTime:
							$Input.Target = target.name
					else:
						lockOnTimer = 0
					
					if target.name == $Input.Target:
						$Hud/TargetRect.show()
						$Hud/TargetRect.position = $CamRoot/Camera.unproject_position(target.global_position) - Vector2(64, 64)
	
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
