extends Node3D

var config : Dictionary :
	set(x):
		config = x
		update_cfg()

func update_cfg():
	var sc = .5 + config["Level"]["current"]*0.02
	$Sketchfab_Scene.scale.x = sc
	$Sketchfab_Scene.scale.y = sc
	$Sketchfab_Scene.scale.z = sc

func _ready():
	update_cfg()

func _process(delta):
	pass
