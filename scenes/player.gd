# player.gd
extends CharacterBody3D

@export var rot_acc = Vector3(0.01, 0.01, 0.04)
@export var max_rot_vel = Vector3(0.015, 0.015, 0.03)
@export var turn_camera_mode=false;

var rot_vel = Vector3()

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
	# Only process on server.
	# EDIT: Let the client simulate player movement too to compesate network input latency.
	# set_physics_process(multiplayer.is_server())


func _physics_process(delta):
	var target_rot_vel = $Input.input_dir*max_rot_vel
	
	rot_vel.x += sign(target_rot_vel.x-rot_vel.x)*rot_acc.x*delta
	rot_vel.y += sign(target_rot_vel.y-rot_vel.y)*rot_acc.y*delta
	rot_vel.z += sign(target_rot_vel.z-rot_vel.z)*rot_acc.z*delta
	
	print(target_rot_vel)
	
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
	global_translate(transform.basis.z*delta*40)
	
	if(input.firering):
		if not multiplayer.is_server():
			return
		shoot()
	
	if(input.missile):
		if not multiplayer.is_server():
			return
		missile()
	
	$Hud/TextureRect.hide()
	if $CamRoot/Camera.current:
		$Input.Target = ""
		for target in get_parent().get_children():
			if target != self:
				if !$CamRoot/Camera.is_position_behind(target.global_position):
					$Input.Target = target.name
					$Hud/TextureRect.show()
					$Hud/TextureRect.position = $CamRoot/Camera.unproject_position(target.global_position) - Vector2(64, 64)

func shoot():
	var b = Bullet.instantiate()
	BulletsCollection.add_child(b, true)
	b.transform = $BulletMuzzle.global_transform

func missile():
	var m = Missile.instantiate()
	m.target = PlayerCollection.get_node($Input.Target)
	BulletsCollection.add_child(m, true)
	m.transform = $BulletMuzzle.global_transform
