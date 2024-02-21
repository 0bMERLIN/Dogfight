extends Node2D

@export var limits = 200
@export var deadzone = 15
@export var dir : Vector2

var paused = false
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.warp_mouse($Control/Crosshair.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !paused:
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()
		$Control/Cursor.position = get_viewport().get_mouse_position()
		dir = $Control/Cursor.position - $Control/Crosshair.position
		dir = dir.limit_length(limits)
		Input.warp_mouse($Control/Crosshair.position+dir)
		if dir.length() < deadzone:
			$Control/Cursor.hide()
			dir = Vector2()
		else:
			$Control/Cursor.show()
		$Control/Cursor.rotation = -(atan2(dir.x, dir.y) + deg_to_rad(180))
		$Control/Cursor.position = $Control/Crosshair.position + dir
		dir /= limits
	else:
		dir = Vector2()

func _notification(n) -> void:
	if n == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		paused = true
	elif n == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		paused = false
