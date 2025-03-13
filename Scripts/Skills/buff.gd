extends Node

var unit_to_buff : Node2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.get_parent().is_in_group("item")):
		unit_to_buff = area.get_parent()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if(area.get_parent() == unit_to_buff):
		unit_to_buff = null
