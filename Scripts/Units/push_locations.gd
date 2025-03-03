extends Node

#What is the tile under the location, this is used to move the unit to this location if its pushed
var tile_under_location : Node2D
#Is the area inside the headquarter, if so, we cant push there
var inside_headquarter : bool = false

#Changes what tile is under the area
func _on_up_area_area_entered(area: Area2D) -> void:
	change_tile_under(area)
func _on_right_area_area_entered(area: Area2D) -> void:
	change_tile_under(area)
func _on_down_area_area_entered(area: Area2D) -> void:
	change_tile_under(area)
func _on_left_area_area_entered(area: Area2D) -> void:
	change_tile_under(area)

func change_tile_under(area):
	if(area.get_parent().is_in_group("tile")):
		tile_under_location = area.get_parent()
	elif(area.get_parent().is_in_group("headquarter")):
		inside_headquarter = true
		tile_under_location = area.get_parent()
