# input.gd
extends MultiplayerSynchronizer

#Syncronize properties
@export var rotation_speeds := Vector3()
@export var speed := 0.0
@export var firering := false
@export var missile := false
@export var Target : String

@onready var cursor = get_parent().get_node("Hud/Hud")

func _ready():
	#Disable for non local player instances
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(delta):
	input_dir = Vector3()
	if Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down"):
		input_dir.x = Input.get_action_strength("ui_up")-Input.get_action_strength("ui_down")
	elif cursor.dir.y != 0:
		input_dir.x = cursor.dir.y
	if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
		input_dir.y = Input.get_action_strength("ui_left")-Input.get_action_strength("ui_right")
	elif cursor.dir.x != 0:
		input_dir.y = -cursor.dir.x
		
	if Input.is_action_pressed("game_d") || Input.is_action_pressed("game_a"):
		input_dir.z = Input.get_action_strength("game_d")-Input.get_action_strength("game_a")
	
	speed += (Input.get_action_strength("game_w")-Input.get_action_strength("game_s"))*delta*50
	
	firering = Input.is_action_pressed("ui_accept")
	missile = Input.is_action_just_pressed("ui_focus_next")
