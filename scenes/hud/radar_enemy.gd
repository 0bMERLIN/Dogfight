extends MeshInstance3D

@export var player := Node
@export var reference := Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_instance_valid(player):
		queue_free()
		return
	position = (player.position - reference.position) / 100
	
