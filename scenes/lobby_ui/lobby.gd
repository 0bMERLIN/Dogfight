extends Control

@export var rootNode : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	
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

func add_player(id: int):
	var character = preload("res://scenes/lobby_ui/player_name.tscn").instantiate()
	#Set the players idD
	character.player_name = str(id)
	$Teams/TeamList.add_player(character)

func del_player(id: int):
	$Teams/TeamList.delete_player(id)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$StartButtons/StartButton.disabled = not multiplayer.is_server() || not $Teams/TeamList.all_players_ready()


func _on_start_button_pressed():
	rootNode.change_world.call_deferred(load("res://scenes/world.tscn"))


func _on_ready_button_pressed():
	$Teams/TeamList.player_ready.rpc(multiplayer.get_unique_id())
