extends Control

@export var player_name := "Spieler1"
var is_ready = false :
	set(value):
		if value: $ReadyLabel.show()
		else: $ReadyLabel.hide()
		is_ready = value

func _ready():
	name = player_name
	$HBoxContainer/Label.text = player_name
	$ReadyLabel.hide()
