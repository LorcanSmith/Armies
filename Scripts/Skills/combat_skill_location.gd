extends Node

@export var units_on_node : Array

func _ready() -> void:
	var sprite = self.find_child("location_sprite")
	sprite.scale = Vector2(0,0)
	self.visible = false
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	get_parent().get_parent().skill_area_entered(area)
	if(get_parent().get_parent().is_in_group("player") and area.get_parent().is_in_group("enemy")):
		units_on_node.append(area.get_parent())
		#print("APPEND - self: player " , get_parent().get_parent().name, ", area: enemy ", area.get_parent().name, ", " , units_on_node)
	elif(get_parent().get_parent().is_in_group("enemy") and area.get_parent().is_in_group("player")):
		units_on_node.append(area.get_parent())
		#print("APPEND - self: enemy " , get_parent().get_parent().name, ", area: player ", area.get_parent().name, ", " , units_on_node)
	elif((get_parent().get_parent().is_in_group("player") and area.get_parent().is_in_group("player")) or (get_parent().get_parent().is_in_group("enemy") and area.get_parent().is_in_group("enemy"))):
		units_on_node.append(area.get_parent())
		#print("APPEND - self: same team " , get_parent().get_parent().name, ", area: same team ", area.get_parent().name, ", " , units_on_node)
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	get_parent().get_parent().skill_area_exited(area)
	if(get_parent().get_parent().is_in_group("player") and area.get_parent().is_in_group("enemy")):
		units_on_node.erase(area.get_parent())
		#print("ERASE - self: player " , get_parent().get_parent().name, ", area: enemy ", area.get_parent().name, ", " , units_on_node)
	elif(get_parent().get_parent().is_in_group("enemy") and area.get_parent().is_in_group("player")):
		units_on_node.erase(area.get_parent())
		#print("ERASE - self: enemy " , get_parent().get_parent().name, ", area: player ", area.get_parent().name, ", " , units_on_node)
	elif((get_parent().get_parent().is_in_group("player") and area.get_parent().is_in_group("player")) or (get_parent().get_parent().is_in_group("enemy") and area.get_parent().is_in_group("enemy"))):
		units_on_node.erase(area.get_parent())
		#print("ERASE - self: same team " , get_parent().get_parent().name, ", area: same team ", area.get_parent().name, ", " , units_on_node)
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "location_popout"):
		self.visible = false
