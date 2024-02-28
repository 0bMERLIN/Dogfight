extends Area3D

func set_selected(s: bool):
	if s: $Marker.mesh = load("res://scenes/ships/selected_sphere.tres")
	else: $Marker.mesh = load("res://scenes/ships/sphere.tres")

func get_active_attachment():
	var cs = get_parent().get_children()
	cs = cs.filter(func (c): return len(c.get_children()) > 2)
	if len(cs) == 0: return null
	return cs[0].get_child(2)

var editing : bool = false :
	set(v):
		if v: $Marker.show()
		else: $Marker.hide()
		editing = v

func _ready():
	pass


func _process(delta):
	pass
