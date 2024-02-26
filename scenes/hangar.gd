extends Node3D

@export var rootNode : Node # game.gd
var selected_upgrade = null

var ship_config : ConfigFile

func create_initial_cfg() -> String:
	ship_config = ConfigFile.new()
	ship_config.load("res://assets/default_conf.cfg")
	return ship_config.encode_to_text()

func _ready():
	ship_config = ConfigFile.new()
	
	if !FileAccess.file_exists("user://ShipConfig.cfg"):
		var file = FileAccess.open("user://ShipConfig.cfg", FileAccess.WRITE)
		file.open("user://ShipConfig.cfg", file.WRITE)
		file.store_string(create_initial_cfg())
		file.close()
	else:
		ship_config.load("user://ShipConfig.cfg")
	
	var current_ship = ship_config.get_value("", "current_ship_name")
	load_ship(current_ship)
	$Credits.text = str(ship_config.get_value("", "credits"))
	
	$NewShipDialogue.all_ships = ship_config.get_value("", "all_ships")

func load_ship(ship_name):
	# load could cause lag spike
	ship_config.set_value("", "current_ship_name", ship_name)
	var s = load(ship_config.get_value(ship_name, "ship_scene")).instantiate()
	s.ship_config = ship_config
	s.editing = true
	
	# remove current ship(s)
	for n in $Ship.get_children():
		$Ship.remove_child(n)
	
	$Ship.add_child(s)
	$ShipName.text = ship_name
	
	# upgrade upgrade list
	for n in $UpgradesContainer/Upgrades.get_children():
		$UpgradesContainer/Upgrades.remove_child(n)
	
	for upgrade_name in ship_config.get_value("", "all_upgrades"):
		var nm = preload("res://scenes/UpgradeName.tscn").instantiate()
		nm.upgrade_name = upgrade_name
		nm.is_bought = upgrade_name in ship_config.get_value("", "upgrades")
		nm.selected.connect(_on_upgrade_selected)
		nm.bought.connect(_on_upgrade_bought)
		$UpgradesContainer/Upgrades.add_child(nm)
	
	create_success_toast("Now editing ship: " + ship_name)


func _on_upgrade_bought(upgrade_name: String):
	var upgrade = ship_config.get_value("", "all_upgrades")[upgrade_name]
	var upgrade_data = upgrade[1]
	var price = upgrade[0]
	
	# handle price
	if not deduct_credits(price): return
	
	# add upgrade to available upgrades
	var ups = ship_config.get_value("", "upgrades")
	ups[upgrade_name] = str_to_var(var_to_str(upgrade_data))
	ship_config.set_value("", "upgrades", ups)
	
	ship_config.save("user://ShipConfig.cfg")
	$Credits.text = str(ship_config.get_value("", "credits"))


func _on_upgrade_selected(upgrade_name: String):
	selected_upgrade = upgrade_name
	$SelectedUpgrade.text = selected_upgrade

func get_ship_names():
	var ship_names = ship_config.get_sections()
	ship_names.remove_at(ship_names.find(""))
	return ship_names

var rot_vel = 0
func _input(event):
	if event is InputEventMouseMotion and event.button_mask & 1:
		rot_vel -= event.relative.x * 0.001
	if event is InputEventMouseButton and event.button_mask & 1:
		var ap = get_attachment_point_under_mouse()
		if ap == null: return
		$Ship.get_child(0).map_attachments(func (x): x.set_selected(false))
		ap.set_selected(true)
		$AttachmentNodeMenu/SelectedAttachmentPoint.text = ap.get_parent().name
		update_data_items()

func update_data_items():
	$Ship.get_child(0).map_attachment_points(
		func (ap):
			if ap.name == $AttachmentNodeMenu/SelectedAttachmentPoint.text:
				update_data_items_for(ap.get_child(0))
	)

func update_data_items_for(ap):
	# clear upgrade data items
	for c in $AttachmentNodeMenu/ScrollContainer/UpgradeData.get_children():
		$AttachmentNodeMenu/ScrollContainer/UpgradeData.remove_child(c)
	
	# add new ones
	var attachment = ap.get_active_attachment()
	if attachment == null: return
	for data_item in attachment.config:
		var data_item_node = load("res://scenes/UpgradeDataItem.tscn").instantiate()
		data_item_node.nm = data_item
		data_item_node.ap = attachment
		data_item_node.on_buy.connect(_on_upgrade_data_item_buy)
		$AttachmentNodeMenu/ScrollContainer/UpgradeData.add_child(data_item_node)

func deduct_credits(cost):
	var credits = ship_config.get_value("", "credits")
	if credits < cost:
		create_success_toast("You spent " + str(cost) + " Credits.")
		return false
	ship_config.set_value("", "credits", credits - cost)
	return true

func _on_upgrade_data_item_buy(upgrade_data_item):
	var current = upgrade_data_item.ap.config[upgrade_data_item.nm]["current"]
	var cost = upgrade_data_item.ap.config[upgrade_data_item.nm]["increment_price"]
	var max = upgrade_data_item.ap.config[upgrade_data_item.nm]["max"]
	
	if current + 1 > max:
		return
	
	# handle price
	if not deduct_credits(cost): return
	
	# update data item
	$Ship.get_child(0).change_attachments(func (a):
		a[$AttachmentNodeMenu/SelectedAttachmentPoint.text][1][upgrade_data_item.nm]["current"] += 1
	)
	upgrade_data_item.ap.update_cfg()
	upgrade_data_item.update_ui()

func _on_remove_attachment_pressed():
	var s = $Ship.get_child(0)
	if $AttachmentNodeMenu/SelectedAttachmentPoint.text != "" and s != null:
		s.del_attachment($AttachmentNodeMenu/SelectedAttachmentPoint.text)
	update_data_items()

func get_attachment_point_under_mouse() -> Node3D:
	var space_state = get_world_3d().direct_space_state
	var cam = $CamPivot/Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	if "collider" in result:
		return result["collider"]
	return null


func _process(event):
	$CamPivot.rotation.y += rot_vel
	rot_vel *= 0.9

func _on_prev_pressed():
	var ship_names = get_ship_names()
	var curr_ship_idx = ship_names.find(ship_config.get_value("", "current_ship_name"))
	var next_ship_idx = (curr_ship_idx-1) % len(ship_names)
	load_ship(ship_names[next_ship_idx])


func _on_next_pressed():
	var ship_names = get_ship_names()
	var curr_ship_idx = ship_names.find(ship_config.get_value("", "current_ship_name"))
	var next_ship_idx = (curr_ship_idx+1) % len(ship_names)
	load_ship(ship_names[next_ship_idx])


func create_toast(msg: String, color: Color, duration_ms: int):
	var t = load("res://scenes/Toast.tscn").instantiate()
	t.msg = msg
	t.color = color
	t.duration_ms = duration_ms
	$ToastsContainer/Toasts.add_child(t)

func create_error_toast(msg: String, duration_ms: int = 2000):
	create_toast(msg, Color.RED, duration_ms)

func create_success_toast(msg: String, duration_ms: int = 2000):
	create_toast(msg, Color.GREEN, duration_ms)
	
# add new upgrade/attachment
func _on_selected_upgrade_pressed():
	var ap = $AttachmentNodeMenu/SelectedAttachmentPoint.text
	if ap == "": return
	var selected_attachment_name = $SelectedUpgrade.text
	if selected_attachment_name == "": return
	var conf = str_to_var(var_to_str(ship_config.get_value("", "upgrades")[selected_attachment_name]))
	if not $Ship.get_child(0).add_attachment(ap, selected_attachment_name, conf):
		create_error_toast("I can't add this attachment here! Just doesn't fit.")
		return
	update_data_items()
	create_success_toast("Added Upgrade " + selected_attachment_name)

func _on_new_ship_pressed():
	$NewShipDialogue.show()
	$NewShip.hide()

func _on_delete_ship_pressed():
	if len(ship_config.get_sections()) <= 2: return
	ship_config.erase_section($ShipName.text)
	_on_next_pressed()

func _on_new_ship_dialogue_create_new_ship(name, data):
	# ship already exists
	if name in ship_config.get_sections(): return
	
	# handle price
	if not deduct_credits(data["price"]): return
	
	ship_config.set_value(name, "ship_scene", data["ship_scene"])
	ship_config.set_value(name, "attachments", {})
	$NewShipDialogue.hide()
	$NewShip.show()
	load_ship(name)
	create_success_toast("You're now the proud owner of " + name + "!")

func _on_new_ship_dialogue_cancel():
	$NewShipDialogue.hide()
	$NewShip.show()
