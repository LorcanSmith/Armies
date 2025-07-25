extends Node

var sound_stream : AudioStream = preload("res://Sounds/test.mp3")
var player
var text_starting_scale : Vector2
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	text_starting_scale = find_child("volume_text").scale
	player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound_stream
	#Set volume percentage
	player.volume_db = Settings.volume
	player.stream.loop = true
	player.play()

func _on_volume_slider_value_changed(value: float) -> void:
	Settings.change_volume(value)
	#Set volume percentage
	player.volume_db = Settings.volume
	find_child("volume_text").scale = text_starting_scale * (1 + ((Settings.volume + 80)/130))


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_settings_button_pressed() -> void:
	find_child("settings_section").visible = !find_child("settings_section").visible


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif(!toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
