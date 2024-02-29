extends Area3D

@export var fired_by : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * 1600 * delta)


func _on_timer_timeout():
	if(multiplayer.is_server()):
		queue_free()


func _on_body_entered(body):
	if multiplayer.is_server():
		if body.hit(1):
			fired_by.kills += 1
		queue_free()
