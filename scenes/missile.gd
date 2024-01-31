extends Area3D

@export var target : Node
@export var speed : float = 30.0
@export var maxTurnSpeed : float = 180.0  # Maximum turning speed in degrees per second

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		# Calculate the direction vector towards the target
		var direction = (target.global_transform.origin - global_transform.origin).normalized()

		# Calculate the angle to rotate
		var angle = global_transform.basis.z.angle_to(direction)

		# Calculate the rotation amount based on the turning speed
		var rotationAmount = min(maxTurnSpeed * delta, angle)

		# Calculate the rotation axis
		var rotationAxis = global_transform.basis.z.cross(direction).normalized()

		# Rotate the missile using rotate() function
		rotate(rotationAxis, deg_to_rad(rotationAmount))

		# Move the missile towards the target
		global_transform.origin += global_transform.basis.z.normalized() * speed * delta
