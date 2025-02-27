extends Node

#Keeps track of if a unit is currently on the tile
var is_empty : bool = true
#Keeps track of the unit which is currently on the tile
var units_on_tile : Array = []

func unit_placed_on(unit):
	is_empty = false
	units_on_tile.append(unit)
