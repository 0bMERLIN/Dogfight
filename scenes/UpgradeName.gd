extends Control

signal selected(name: String)
signal bought(name: String)

var is_bought : bool : 
	set(x):
		$Button.disabled = not x
		if x: $Buy.hide()
		else: $Buy.show()
		is_bought = x

@export var upgrade_name : String

func _ready():
	$Button.text = upgrade_name

func _on_button_pressed():
	selected.emit(upgrade_name)

func _on_buy_pressed():
	is_bought = true
	bought.emit(upgrade_name)
