extends Control

@export var rootNode : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if not multiplayer.is_server():
		$StartButtons/StartButton.disabled = true
	
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
	#Set the players id
	character.player_name = str(id)
	$Teams/TeamList.add_player(character)

func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	rootNode.change_world.call_deferred(load("res://scenes/world.tscn"))
	
