extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_player(player_name):
	$Texture/PlayerList.add_child(player_name, true)

func delete_player(player_id):
	if not $Texture/PlayerList.has_node(str(player_id)):
		return
	$Texture/PlayerList.get_node(str(player_id)).queue_free()
