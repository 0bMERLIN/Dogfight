extends Area3D

func set_selected(s: bool):
	if s: $MeshInstance3D.mesh = load("res://scenes/ships/selected_sphere.tres")
	else: $MeshInstance3D.mesh = load("res://scenes/ships/sphere.tres")

func get_active_attachment():
	var cs = get_parent().get_children()
	cs = cs.filter(func (c): return len(c.get_children()) > 2)
	if len(cs) == 0: return null
	return cs[0].get_child(2)

func _ready():
	pass


func _process(delta):
	pass
