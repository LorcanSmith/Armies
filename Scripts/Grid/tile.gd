extends Node

#Keeps track of if a unit is currently on the tile
var is_empty : bool = true
#Keeps track of the unit which is currently on the tile
var unit_on_tile : Node2D = null

func unit_placed_on(unit):
	is_empty = false
	unit_on_tile = unit
