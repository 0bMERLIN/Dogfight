extends Control

signal create_new_ship(name: String, data: Dictionary)
signal cancel()

var all_ships : Dictionary :
	set(x):
		all_ships = x
		for s in all_ships:
			($Type as OptionButton).add_item(s)
		var nm = all_ships.keys()[$Type.selected]
		$Create.text = "Create (" + str(all_ships[nm]["price"]) + " Credits)"

func _on_type_item_selected(idx):
	var nm = all_ships.keys()[$Type.selected]
	$Create.text = "Create (" + str(all_ships[nm]["price"]) + ")"

func _on_create_pressed():
	var nm = all_ships.keys()[$Type.selected]
	create_new_ship.emit($Name.text, str_to_var(var_to_str(all_ships[nm])))

func _on_cancel_pressed():
	cancel.emit()
