extends Node3D

@export var rootNode : Node # game.gd

# TODO: transmit saved current ship config on ready!

var ship_config : ConfigFile
# hangar mutates ship_config[current_ship_name].

func create_initial_cfg() -> String:
	ship_config = ConfigFile.new()
	ship_config.set_value("", "current_ship_name", "MyDemoShip")
	ship_config.set_value("MyDemoShip", "ship_scene", "res://scenes/ships/demo_ship.tscn")
	ship_config.set_value("MyDemoShip", "attachments", {})
	return ship_config.encode_to_text()

func get_current_ship_config() -> ConfigFile:
	var c = ConfigFile.new()
	var current_ship_name = ship_config.get_value("", "current_ship_name")
	for k in ship_config.get_section_keys(current_ship_name):
		c.set_value("", k, ship_config.get_value(current_ship_name, k))
	c.set_value("", "current_ship_name", current_ship_name)
	return c

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

func load_ship(ship_name):
	# load could cause lag spike
	ship_config.set_value("", "current_ship_name", ship_name)
	var s = load(ship_config.get_value(ship_name, "ship_scene")).instantiate()
	s.ship_config = get_current_ship_config()
	
	# remove current ship(s)
	for n in $Ship.get_children():
		$Ship.remove_child(n)
		
	$Ship.add_child(s)
	$ShipName.text = ship_name

func get_ship_names():
	var ship_names = ship_config.get_sections()
	ship_names.remove_at(ship_names.find(""))
	return ship_names

var rot_vel = 0
func _input(event):
	if event is InputEventMouseMotion and event.button_mask & 1:
		rot_vel -= event.relative.x * 0.001

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
