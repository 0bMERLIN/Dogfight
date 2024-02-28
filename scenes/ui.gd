extends Control


class_name ui
signal _on_host_pressed
signal _on_connect_pressed
@onready var setting_screen=$Setting_screen
@onready var before_game_screen=$before_game_screen
@onready var starting_game_screen=$starting_game_screen
@onready var join_lobby_screen=$join_lobby_screen


func _ready():
	if FileAccess.file_exists("user://save_IP.dat"):
		var file=FileAccess.open("user://save_IP.dat", FileAccess.READ)
		var savedIP=file.get_as_text()
		$join_lobby_screen/CenterContainer/LineEdit.text=savedIP


func _on_play_button_pressed():
	starting_game_screen.visible=true
	before_game_screen.visible=false

func _on_settings_button_pressed():
	setting_screen.visible=true
	before_game_screen.visible=false

func _on_exit_settings_pressed():
	setting_screen.visible=false
	before_game_screen.visible=true


func _on_quit_button_pressed():
	get_tree().quit()



func _on_createlobby_button_pressed():
	_on_host_pressed.emit()


func _on_joinlobby_button_pressed():
	join_lobby_screen.visible=true
	starting_game_screen.visible=false


func _on_exit_starting_pressed():
	starting_game_screen.visible=false
	before_game_screen.visible=true


func _on_exit_join_lobby_pressed():
	join_lobby_screen.visible=false
	starting_game_screen.visible=true


func _on_start_button_pressed():
	var file=FileAccess.open("user://save_IP.dat", FileAccess.WRITE)
	file.store_string($join_lobby_screen/CenterContainer/LineEdit.text)
	_on_connect_pressed.emit($join_lobby_screen/CenterContainer/LineEdit.text)
