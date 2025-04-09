extends Node

@export var is_adjective : bool

var word : String


func _on_pressed() -> void:
	find_parent("game_manager").word_pressed(is_adjective, word)
