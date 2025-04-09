extends Node

var units_on_node : Array

func _ready() -> void:
	var sprite = self.find_child("location_sprite")
	sprite.scale = Vector2(0,0)
	self.visible = false
	if(get_parent().get_parent().skill_heal > 0):
		self.find_child("sword").visible = false
		self.find_child("cross").visible = true
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	get_parent().get_parent().skill_area_entered(area)
	if(get_parent().get_parent().is_in_group("player") and area.get_parent().is_in_group("enemy")):
		units_on_node.append(area.get_parent())
	elif(get_parent().get_parent().is_in_group("enemy") and area.get_parent().is_in_group("player")):
		units_on_node.append(area.get_parent())
	elif((get_parent().get_parent().is_in_group("player") and area.get_parent().is_in_group("player")) or (get_parent().get_parent().is_in_group("enemy") and area.get_parent().is_in_group("enemy"))):
		units_on_node.append(area.get_parent())
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	get_parent().get_parent().skill_area_exited(area)
	if(get_parent().get_parent().is_in_group("player") and area.get_parent().is_in_group("enemy")):
		units_on_node.erase(area.get_parent())
	elif(get_parent().get_parent().is_in_group("enemy") and area.get_parent().is_in_group("player")):
		units_on_node.erase(area.get_parent())
	elif((get_parent().get_parent().is_in_group("player") and area.get_parent().is_in_group("player")) or (get_parent().get_parent().is_in_group("enemy") and area.get_parent().is_in_group("enemy"))):
		units_on_node.erase(area.get_parent())
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "location_popout"):
		self.visible = false
