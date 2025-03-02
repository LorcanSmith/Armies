extends Node

var movement_tile

func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.get_parent().is_in_group("tile")):
		movement_tile = area.get_parent()
