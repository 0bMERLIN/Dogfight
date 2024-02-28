extends Node3D

var ship_config : ConfigFile

func get_ship_name() -> String:
	return ship_config.get_value("", "current_ship_name")

var editing = false :
	set(v):
		map_attachments(func(a):
			if v:
				a.editing = true
			else:
				a.editing = false)
		editing = v

func del_attachment(attachment_point_name):
	map_attachment_points(func (p: Node3D):
		if p.name == attachment_point_name:
			for n in p.get_children():
				if len(n.get_children()) != 2:
					var n_position = n.position
					p.remove_child(n)
					var new_ap = preload("res://scenes/AttachmentPoint.tscn").instantiate()
					new_ap.position = n_position
					new_ap.set_selected(true)
					new_ap.name = n.name
					p.add_child(new_ap)
					# update ship config
					change_attachments(func (attachments : Dictionary):
						attachments.erase(attachment_point_name))
					)

func spawn_attachment(attachment_point_name, name, conf) -> bool:
	# find attachment node
	var ap = $AttachmentPoints.find_child(attachment_point_name)
	if ap == null: return false
	var ns = ap.get_children().filter(func (c): return c.name == name)
	if ns == []: return false
	var n = ns[0]
	
	# check if free
	if len(ap.get_children().filter(func (c): return len(c.get_children()) > 2)) > 0:
		return false
	
	# add to attachment node
	if len(n.get_children()) == 2:
		var a = load("res://scenes/attachments/"+name+".tscn").instantiate()
		a.config = conf
		n.add_child(a)
		return true
	return false

func add_attachment(attachment_point_name, name, conf) -> bool:
	if spawn_attachment(attachment_point_name, name, conf):
		# update ship config
		change_attachments(func (attachments):
			attachments[attachment_point_name] = [name, conf])
		return true
	return false

func change_attachments(f):
	var old_attachments = ship_config.get_value(get_ship_name(), "attachments")
	f.call(old_attachments)
	ship_config.set_value(get_ship_name(), "attachments", old_attachments)
	ship_config.save("user://ShipConfig.cfg")

func map_attachments(fn):
	for p in $AttachmentPoints.get_children():
		for a in p.get_children():
			fn.call(a)

func map_attachment_points(fn):
	for p in $AttachmentPoints.get_children():
		fn.call(p)

func _ready():
	var attachments = ship_config.get_value(get_ship_name(), "attachments")
	for a_point_name in attachments:
		spawn_attachment(a_point_name, attachments[a_point_name][0], attachments[a_point_name][1])

