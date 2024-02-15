# input.gd
extends MultiplayerSynchronizer

#Syncronize properties
@export var input_dir := Vector3()
@export var speed := 10.0
@export var firering := false
@export var missile := false
@export var Target : String

func _ready():
	#Disable for non local player instances
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(delta):
	input_dir = Vector3()
	if Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down"):
		input_dir.x = Input.get_action_strength("ui_up")-Input.get_action_strength("ui_down")
	elif $Hud/Hud.dir.y != 0:
		input_dir.x = $Hud/Hud.dir.y
	if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
		input_dir.y = Input.get_action_strength("ui_left")-Input.get_action_strength("ui_right")
	elif $Hud/Hud.dir.x != 0:
		input_dir.y = -$Hud/Hud.dir.x
		
	if Input.is_action_pressed("game_d") || Input.is_action_pressed("game_a"):
		input_dir.z = Input.get_action_strength("game_d")-Input.get_action_strength("game_a")
	
	
	firering = Input.is_action_pressed("ui_accept")
	missile = Input.is_action_just_pressed("ui_focus_next")
