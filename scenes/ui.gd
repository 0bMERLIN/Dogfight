extends CanvasLayer

class_name ui
signal game_started
@onready var end_of_game_screen =$End_of_game_screen
@onready var setting_screen=$Setting_screen
@onready var before_game_screen=$before_game_screen

func _ready():
	pass
	
func on_game_over():
	end_of_game_screen.visible=true
	
func _on_restart_button_pressed():
	get_tree().reload_current_scene()


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")



func _on_settings_button_pressed():
	setting_screen.visible=true
	before_game_screen.visible=false

func _on_exit_settings_pressed():
	setting_screen.visible=false
	before_game_screen.visible=true


func _on_quit_button_pressed():
	get_tree().quit()

