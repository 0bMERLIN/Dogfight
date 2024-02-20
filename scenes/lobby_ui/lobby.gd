extends Control

var rootNode : Node
@export var start_time_s : int
var start_timer : float = start_time_s

@onready var hangar

func _ready():
	
	rootNode = get_parent().get_parent()
	
	# create hangar
	hangar = preload("res://scenes/hangar.tscn").instantiate()
	hangar.rootNode = rootNode
	$SubViewportContainer/SubViewport.add_child(hangar)
	
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


func _process(delta):
	if $Teams/TeamList.all_players_ready():
		start_timer -= delta
	else:
		start_timer = start_time_s
	
	$StartButtons/StartCountdown.text = str(int(start_timer))
	if multiplayer.is_server() && start_timer <= 0:
		rootNode.change_world.call_deferred(load("res://scenes/world.tscn"))
		


func _on_ready_button_toggled(toggled_on):
	$Teams/TeamList.set_ready.rpc(multiplayer.get_unique_id(), toggled_on)
	#rootNode.set_player_info(multiplayer.get_unique_id(), hangar.get_current_ship_config().encode_to_text())
	rootNode.set_player_info.rpc(multiplayer.get_unique_id(), hangar.get_current_ship_config().encode_to_text())
