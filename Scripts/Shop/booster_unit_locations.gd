extends Node

var unit_ID : int
var unit : Node2D
var tooltip : Node2D

func _ready() -> void:
	tooltip = find_parent("shop_manager").find_child("Tooltip")
	
func _on_area_2d_pressed() -> void:
	find_parent("choose_unit_UI").get_parent().selected_unit(unit, unit_ID)
	tooltip.update_tooltip(unit_ID, 0, 0)
