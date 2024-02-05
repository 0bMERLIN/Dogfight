extends Control

@export var player_name := "Spieler1"

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/Label.text = player_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
