extends Area3D

@export var target : Node
@export var speed : float = 140.0
@export var maxTurnSpeed : float = 210.0  # Maximum turning speed in degrees per second
@export var exploded = false

@export var fired_by : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if exploded:
		explode()
	if target && $Animation.is_stopped():
		# Calculate the direction vector towards the target
		var dist = (target.global_transform.origin - global_transform.origin)
		var dir = dist.normalized()
		
		if dist.length() < 10:
			explode()
			exploded = true
			speed = 0
			if multiplayer.is_server():
				if target.hit(30):
					fired_by.kills += 1

		# Calculate the angle to rotate
		var angle = global_transform.basis.z.angle_to(dir)

		# Calculate the rotation amount based on the turning speed
		var rotationAmount = min(maxTurnSpeed * delta, angle)

		# Calculate the rotation axis
		var rotationAxis = global_transform.basis.z.cross(dir).normalized()

		# Rotate the missile using rotate() function
		rotate(rotationAxis, deg_to_rad(rotationAmount))

	global_transform.origin += global_transform.basis.z.normalized() * speed * delta

func explode():
	$Node3D.emit()
	$Animation.start()
	$Sketchfab_Scene.hide()

func _on_timer_timeout():
	if multiplayer.is_server():
		queue_free()


func _on_despawn_timeout():
	$Node3D.emit()
	$Animation.start()
	speed = 0
	$Sketchfab_Scene.hide()
	
