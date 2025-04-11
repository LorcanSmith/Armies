extends Node

var unit_to_buff : Node2D

func _ready() -> void:
	var sprite = self.find_child("location_sprite")
	sprite.scale = Vector2(0,0)
	self.visible = false
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.name == "Area2D - Tile Collision" and area.get_parent().bought and self.get_parent().get_parent() != area.get_parent() and !self.get_parent().get_parent().disabled):
		unit_to_buff = area.get_parent()
func _on_area_2d_area_exited(area: Area2D) -> void:
	if(area.get_parent() == unit_to_buff):
		unit_to_buff = null
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "location_popout"):
		self.visible = false
