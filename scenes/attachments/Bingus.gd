extends Node3D

var config : Dictionary

func set_cfg(c):
	config = c
	$Sketchfab_Scene.scale *= config["Level"]

func _ready():
	set_cfg(config)

func _process(delta):
	pass
