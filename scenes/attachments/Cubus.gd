extends Node3D

var config : Dictionary :
	set(x):
		config = x
		update_cfg()

func update_cfg():
	var sc = 1 + config["Cubusness"]["current"]*0.02
	$MeshInstance3D.scale.x = sc
	$MeshInstance3D.scale.y = sc
	$MeshInstance3D.scale.z = sc

func _ready():
	update_cfg()

func _process(delta):
	pass
