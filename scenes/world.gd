extends Node3D

@export var rootNode : Node

const RANDOM_SPAWN_RADIUS := 5.0

func _ready():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	#Only spawn players as the server
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	#Spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)

	#Spawn the local player unless this is a dedicated server
	if not OS.has_feature("dedicated_server"):
		add_player(1)


func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	var character = preload("res://scenes/player.tscn").instantiate()
	#Set the players id
	character.player = id
	#Spawn the player at a random position
	var pos := Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector3(pos.x * RANDOM_SPAWN_RADIUS * randf(), 0, pos.y * RANDOM_SPAWN_RADIUS * randf())
	character.name = str(id)
	character.BulletsCollection = $Bullets
	character.PlayerCollection = $Players
	$Players.add_child(character, true)

func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()
