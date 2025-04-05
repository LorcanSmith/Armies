extends Node

var movement_tile

var hq : Node2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.get_parent().is_in_group("tile")):
		movement_tile = area.get_parent()
	elif(area.get_parent().is_in_group("headquarter")):
		movement_tile = null
		hq = area.get_parent()
