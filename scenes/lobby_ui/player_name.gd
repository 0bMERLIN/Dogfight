extends Control

@export var player_name := "Spieler1"
var is_ready = false

# Called when the node enters the scene tree for the first time.
func _ready():
	name = player_name
	$HBoxContainer/Label.text = player_name
	$ReadyLabel.hide()

func player_ready():
	$ReadyLabel.show()
	is_ready = true
