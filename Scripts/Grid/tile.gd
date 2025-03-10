extends Node

#Keeps track of if a unit is currently on the tile
var is_empty : bool = true
#Keeps track of the unit which is currently on the tile
var units_on_tile : Array = []

func unit_placed_on(unit):
	is_empty = false
	if(!units_on_tile.has(unit)):
		units_on_tile.append(unit)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.is_in_group("tilemap")):
		area.get_parent().visiblity(false)
