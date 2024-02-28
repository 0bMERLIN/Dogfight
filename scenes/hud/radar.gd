extends Node3D

@export var players_scene : Node
@export var main_player : Node
@export var enemy_marker : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	for player in players_scene.get_children():
		if player != main_player:
			var playerpoint = enemy_marker.instantiate()
			playerpoint.player = player
			playerpoint.reference = main_player
			add_child(playerpoint)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Reference.global_rotation = main_player.global_rotation
