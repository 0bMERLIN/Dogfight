extends Area3D

@export var target : Node
@export var speed : float = 60.0
@export var maxTurnSpeed : float = 190.0  # Maximum turning speed in degrees per second

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		# Calculate the direction vector towards the target
		var dist = (target.global_transform.origin - global_transform.origin)
		var dir = dist.normalized()
		
		if dist.length() < 10:
			$Node3D.emit()
			$Animation.start()
			speed = 0
			$Sketchfab_Scene.hide()
			if multiplayer.is_server():
				target.hit(30)

		# Calculate the angle to rotate
		var angle = global_transform.basis.z.angle_to(dir)

		# Calculate the rotation amount based on the turning speed
		var rotationAmount = min(maxTurnSpeed * delta, angle)

		# Calculate the rotation axis
		var rotationAxis = global_transform.basis.z.cross(dir).normalized()

		# Rotate the missile using rotate() function
		rotate(rotationAxis, deg_to_rad(rotationAmount))

	global_transform.origin += global_transform.basis.z.normalized() * speed * delta


func _on_timer_timeout():
	queue_free()


func _on_despawn_timeout():
	$Node3D.emit()
	$Animation.start()
	speed = 0
	$Sketchfab_Scene.hide()
	
