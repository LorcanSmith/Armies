extends Node

var unit_ID : int
var unit : Node2D
var tooltip : Node2D

func _ready() -> void:
	tooltip = find_parent("shop_manager").find_child("Tooltip")
	
func _on_area_2d_pressed() -> void:
	if(get_parent().name == "base_locations"):
		find_parent("base_crate").selected_unit(unit)
	elif (get_parent().name == "upgraded_base_locations"):
		find_parent("shop_item_generator").selected_unit(unit)
	else:
		find_parent("choose_unit_UI").get_parent().selected_unit(unit)


func _on_unit_button_mouse_entered() -> void:
	tooltip.update_tooltip(unit_ID, 0, 0)
