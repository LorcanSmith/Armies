extends Node

var unit_to_buff : Node2D

func _ready() -> void:
	var sprite = self.find_child("location_sprite")
	sprite.scale = Vector2(0,0)
	self.visible = false
	if(get_parent().get_parent().skill_heal > 0):
		self.find_child("sword").visible = false
		self.find_child("cross").visible = true
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	get_parent().get_parent().skill_area_entered(area)
func _on_area_2d_area_exited(area: Area2D) -> void:
	get_parent().get_parent().skill_area_exited(area)
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "location_popout"):
		self.visible = false
