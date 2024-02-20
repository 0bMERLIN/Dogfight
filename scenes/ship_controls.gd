extends Node3D

@export var player : Node3D

func _ready():
	pass

func _process(delta):
	if player != null:
		$CamRoot.rotation.y = -player.rotation.y
		$CamRoot.rotation.x = player.rotation.x
