extends Control

@export var rootNode : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	rootNode.change_world.call_deferred(load("res://scenes/world.tscn"))
