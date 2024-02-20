extends Node3D

var ship_config : ConfigFile

func add_attachment(attachment_point_name, name, conf) -> bool:
	var ap = $AttachmentPoints.find_child(attachment_point_name)
	if ap == null: return false
	var n = ap.find_child(name)
	if n == null: return false
	
	if len(n.get_children()) == 0:
		var a = load("res://scenes/attachments/"+name+".tscn").instantiate()
		a.config = conf
		n.add_child(a)
		return true
	
	return false

func _ready():
	var attachments = ship_config.get_value("", "attachments") as Dictionary
	for a_point_name in attachments:
		add_attachment(a_point_name, attachments[a_point_name][0], attachments[a_point_name][1])

func _process(delta):
	pass
