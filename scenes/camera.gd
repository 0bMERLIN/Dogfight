extends Camera3D

const ANGULAR_SPEED_PITCH = 50.0/3.5
const ANGULAR_SPEED_ROLL = 80.0/3.5
const ANGULAR_SPEED_YAW = 50.0/3.5

const MAX_ROT_LIM_R = 0.2
const MAX_ROT_LIM_Y = 0.2
const MAX_ROT_LIM_P = 0.2

var rot_lim_r = 0
var rot_lim_y = 0
var rot_lim_p = 0

@onready var cam_root = get_parent()

@export var input : MultiplayerSynchronizer

func _ready():
	#ship = get_parent()
	pass

func _process(delta):
	rotate_object_local(Vector3(0, 0, 1), input.rotation_speeds.y * ANGULAR_SPEED_ROLL * delta * (PI / 180.0))
	if abs(input.rotation_speeds.y) < 0.9:
		rot_lim_r = max(0, rot_lim_r-0.005)
	else:
		rot_lim_r = MAX_ROT_LIM_R
	rotation = rotation.clamp(Vector3(-100, -100, -rot_lim_r), Vector3(100, 100, rot_lim_r))
	
	cam_root.rotation.y += -input.rotation_speeds.z * ANGULAR_SPEED_YAW * delta * (PI / 180.0)
	if abs(input.rotation_speeds.z) < 0.9:
		rot_lim_y = max(0, rot_lim_y-0.005)
	else:
		rot_lim_y = MAX_ROT_LIM_Y
	cam_root.rotation.y = clamp(cam_root.rotation.y, -rot_lim_y, rot_lim_y)
	
	cam_root.rotation.x += -input.rotation_speeds.x * ANGULAR_SPEED_PITCH * delta * (PI / 180.0)
	if abs(input.rotation_speeds.x) < 0.9:
		rot_lim_p = max(0, rot_lim_p-0.005)
	else:
		rot_lim_p = MAX_ROT_LIM_P
	cam_root.rotation.x = clamp(cam_root.rotation.x, -rot_lim_p, rot_lim_p)
