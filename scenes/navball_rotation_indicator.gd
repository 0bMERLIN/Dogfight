extends Sprite2D

@export var player : Node3D

func _process(delta):
	rotation = player.rotation.z
