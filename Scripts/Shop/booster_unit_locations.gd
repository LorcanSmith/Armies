extends Node

var unit_ID : int
var unit : Node2D

var mouse_over : bool = false

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	
func _input(event):
	if event is InputEventMouseButton:
		#Checks to see if something has happened with the left mouse button
		if event.button_index == MOUSE_BUTTON_LEFT:
			#Checks to see if a pressed event happened whilst the mouse was over the item 
			if(event.pressed and mouse_over):
				find_parent("choose_unit_UI").get_parent().selected_unit(unit, unit_ID)
