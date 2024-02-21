extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * 160 * delta)


func _on_timer_timeout():
	if(multiplayer.is_server()):
		queue_free()
