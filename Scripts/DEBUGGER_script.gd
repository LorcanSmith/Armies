extends Node

#Are you placing friendly or enemy units in the shop
var place_enemy : bool = false

func _on_place_enemy_button_toggled(toggled_on: bool) -> void:
	DebuggerScript.place_enemy = toggled_on
