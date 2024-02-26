# player.gd
extends CharacterBody3D

const ANGULAR_SPEED_PITCH = 50.0
const ANGULAR_SPEED_ROLL = 80.0
const ANGULAR_SPEED_YAW = 50.0

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

func _ready():
	var rootNode = get_tree().root.get_child(0)
	Ship_config = rootNode.player_ship_info_CFG[player]
	
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		$CamRoot/Camera.current = true
	else:
		$Hud/SubViewportContainer.hide()
	$CamRoot/Camera.input = input
	
	var s = load(Ship_config.get_value(Ship_config.get_value("", "current_ship_name"), "ship_scene")).instantiate()
	s.ship_config = Ship_config
	add_child(s)
	# Only process on server.
	# EDIT: Let the client simulate player movement too to compesate network input latency.
	# set_physics_process(multiplayer.is_server())


func _physics_process(delta):
	rotate_object_local(Vector3(1, 0, 0), input.rotation_speeds.x * ANGULAR_SPEED_PITCH * delta * (PI / 180.0))
	rotate_object_local(Vector3(0, 0, 1), input.rotation_speeds.y * ANGULAR_SPEED_ROLL * delta * (PI / 180.0))
	rotate_object_local(Vector3(0, 1, 0), input.rotation_speeds.z * ANGULAR_SPEED_YAW * delta * (PI / 180.0))
	
	# Move the plane forward.
	translate(Vector3(0, 0, input.speed * delta))
	
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
