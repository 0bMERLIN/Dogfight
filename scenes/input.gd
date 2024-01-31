# input.gd
extends MultiplayerSynchronizer

#Syncronize properties
@export var rotation_speeds := Vector3()
@export var speed := 10.0
@export var firering := false
@export var missile := false
@export var Target : String

func _ready():
	#Disable for non local player instances
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(delta):
	#Get the input
	rotation_speeds.x = lerp(rotation_speeds.x, Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down"), 0.1)
	rotation_speeds.y = lerp(rotation_speeds.y, Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), 0.1)
	rotation_speeds.z = lerp(rotation_speeds.z, Input.get_action_strength("game_a") - Input.get_action_strength("game_d"), 0.1)

	speed += Input.get_action_strength("game_w")/1.2
	speed -= Input.get_action_strength("game_s")/1.2
	
	speed = clamp(speed, 0, 20)
	
	
	firering = Input.is_action_pressed("ui_accept")
	missile = Input.is_action_just_pressed("ui_focus_next")
