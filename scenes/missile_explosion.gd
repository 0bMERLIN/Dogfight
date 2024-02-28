extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func emit():
	$spark1/Sparks.emitting = true
	$spark1/Flash.emitting = true
	$spark1/Fire.emitting = true
	$spark1/Smoke.emitting = true
