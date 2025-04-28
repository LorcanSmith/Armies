extends Node

@export var is_adjective : bool

var word : String


func _on_pressed() -> void:
	if(word == null):
		word = "Test"
	find_parent("game_manager").word_pressed(is_adjective, word)
