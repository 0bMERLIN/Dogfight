extends Control


func add_player(player_name):
	$Texture/PlayerList.add_child(player_name, true)

func delete_player(player_id):
	if not $Texture/PlayerList.has_node(str(player_id)):
		return
	$Texture/PlayerList.get_node(str(player_id)).queue_free()

@rpc("any_peer", "call_local", "reliable")
func set_ready(player_id, ready: bool):
	if not $Texture/PlayerList.has_node(str(player_id)):
		return
	var p = $Texture/PlayerList.get_node(str(player_id))
	p.is_ready = ready

func all_players_ready() -> bool:
	return $Texture/PlayerList.get_children().all(func(x): return x.is_ready)
