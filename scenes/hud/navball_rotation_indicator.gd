extends Control

@export var player : Node3D

func _process(delta):
	rotation = get_parent().get_parent().get_parent().get_parent().rotation.z
