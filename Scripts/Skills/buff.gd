extends Node

var unit_to_buff : Node2D
var tile_when_no_unit : Node2D

var buff_health_amount : int = 0
var buff_damage_amount : int = 0

func _ready() -> void:
	self.visible = false
	buff_health_amount = get_parent().get_parent().health_buff
	buff_damage_amount = get_parent().get_parent().damage_buff
func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.name == "Area2D - Tile Collision" and area.get_parent().bought and self.get_parent().get_parent() != area.get_parent() and !self.get_parent().get_parent().disabled):
		if(unit_to_buff):
			#Checks to make sure the unit hasnt died, weird way to do it, but only way i could get it to work
			if(unit_to_buff.find_child("AnimatedSprite2D")):
				unit_to_buff.find_child("AnimatedSprite2D").self_modulate = Color(1,1,1,1)
				unit_to_buff.find_child("health_upgrade_preview_sprite").visible = false
				unit_to_buff.find_child("damage_upgrade_preview_sprite").visible = false
				unit_to_buff.find_child("health_downgrade_preview_sprite").visible = false
				unit_to_buff.find_child("damage_downgrade_preview_sprite").visible = false
			unit_to_buff = null
		
		unit_to_buff = area.get_parent()
		var dictionary = preload("res://Scripts/Units/dictionary.gd")
		var dictionary_instance = dictionary.new()
		var unit_dictionary = dictionary_instance.unit_scenes[unit_to_buff.unit_ID].instantiate()
		var parent_unit = get_parent().get_parent()
		if(!get_parent().get_parent().check_if_can_buff_unit(unit_dictionary)):
			unit_to_buff = null
		else:
			##Checks for specific units
			#Diplodocus
			if(parent_unit.unit_ID == 17):
				if(unit_to_buff.current_health >= parent_unit.current_health):
					unit_to_buff = null
			#Wizard
			elif(parent_unit.unit_ID == 23):
				if(!unit_to_buff.can_buff):
					unit_to_buff = null
		unit_dictionary.queue_free()
	if(area.get_parent().is_in_group("tile")):
		if(tile_when_no_unit):
			tile_when_no_unit.find_child("Sprite2D").self_modulate = Color(1,1,1,1)
			tile_when_no_unit = null
		tile_when_no_unit = area.get_parent()
		if(self.visible):
			if(buff_damage_amount > 0 or buff_health_amount > 0):
				tile_when_no_unit.find_child("Sprite2D").self_modulate = Color(0.075,1,0.065,1)
			elif(buff_damage_amount < 0 or buff_health_amount < 0):
				tile_when_no_unit.find_child("Sprite2D").self_modulate = Color(1,0,.038,1)
			#Has a buff but doesn't change unit health or damage (eg. wizard triggering buffs twice)
			elif(buff_damage_amount == 0 and buff_damage_amount == 0):
				tile_when_no_unit.find_child("Sprite2D").self_modulate = Color(0.075,1,0.065,1)
	if(self.visible):
		turn_highlights_on()
func _on_area_2d_area_exited(area: Area2D) -> void:
	if(area.get_parent() == unit_to_buff):
		#Checks to make sure the unit hasnt died, weird way to do it, but only way i could get it to work
		if(unit_to_buff.find_child("AnimatedSprite2D")):
			unit_to_buff.find_child("AnimatedSprite2D").self_modulate = Color(1,1,1,1)
			unit_to_buff.find_child("health_upgrade_preview_sprite").visible = false
			unit_to_buff.find_child("damage_upgrade_preview_sprite").visible = false
			unit_to_buff.find_child("health_downgrade_preview_sprite").visible = false
			unit_to_buff.find_child("damage_downgrade_preview_sprite").visible = false
		unit_to_buff = null
	elif(area.get_parent() == tile_when_no_unit):
		tile_when_no_unit.find_child("Sprite2D").self_modulate = Color(1,1,1,1)
		tile_when_no_unit = null


func _on_visibility_changed() -> void:
	if(!self.visible):
		if(unit_to_buff != null):
			#Checks to make sure the unit hasnt died, weird way to do it, but only way i could get it to work
			if(unit_to_buff.find_child("AnimatedSprite2D")):
				unit_to_buff.find_child("AnimatedSprite2D").self_modulate = Color(1,1,1,1)
				unit_to_buff.find_child("health_upgrade_preview_sprite").visible = false
				unit_to_buff.find_child("damage_upgrade_preview_sprite").visible = false
				unit_to_buff.find_child("health_downgrade_preview_sprite").visible = false
				unit_to_buff.find_child("damage_downgrade_preview_sprite").visible = false
		if(tile_when_no_unit):
			tile_when_no_unit.find_child("Sprite2D").self_modulate = Color(1,1,1,1)
	elif(self.visible):
		turn_highlights_on()

func turn_highlights_on():
	if(unit_to_buff):
		#Plays an animation
		if(!unit_to_buff.find_child("health_upgrade_preview_sprite").visible and !unit_to_buff.find_child("health_downgrade_preview_sprite").visible and !unit_to_buff.find_child("damage_upgrade_preview_sprite").visible and !unit_to_buff.find_child("damage_downgrade_preview_sprite").visible):
			unit_to_buff.find_child("buff_preview_animator").play("popin")

		if(buff_health_amount > 0):
			unit_to_buff.find_child("AnimatedSprite2D").self_modulate = Color(0.075,1,0.065,1)
			unit_to_buff.find_child("health_upgrade_preview_sprite").visible = true
			unit_to_buff.find_child("health_upgrade_preview_text").text = str("+", buff_health_amount)
		elif(buff_health_amount < 0):
			unit_to_buff.find_child("AnimatedSprite2D").self_modulate = Color(1,0,.038,1)
			unit_to_buff.find_child("health_downgrade_preview_sprite").visible = true
			unit_to_buff.find_child("health_downgrade_preview_text").text = str(buff_health_amount)
		
		if(buff_damage_amount > 0):
			unit_to_buff.find_child("AnimatedSprite2D").self_modulate = Color(0.075,1,0.065,1)
			unit_to_buff.find_child("damage_upgrade_preview_sprite").visible = true
			unit_to_buff.find_child("damage_upgrade_preview_text").text = str("+", buff_damage_amount)
		elif(buff_damage_amount < 0):
			unit_to_buff.find_child("AnimatedSprite2D").self_modulate = Color(1,0,.038,1)
			unit_to_buff.find_child("damage_downgrade_preview_sprite").visible = true
			unit_to_buff.find_child("damage_downgrade_preview_text").text = str(buff_damage_amount)
	
		#For stuff like wizards who dont actually give buffs but instead trigger abilities twice
		if(buff_damage_amount == 0 and buff_health_amount == 0):
			unit_to_buff.find_child("AnimatedSprite2D").self_modulate = Color(0.075,1,0.065,1)
			
	if(tile_when_no_unit):
		if(buff_damage_amount > 0 or buff_health_amount > 0):
			tile_when_no_unit.find_child("Sprite2D").self_modulate = Color(0.075,1,0.065,1)
		elif(buff_damage_amount < 0 or buff_health_amount < 0):
			tile_when_no_unit.find_child("Sprite2D").self_modulate = Color(1,0,.038,1)
		
		#For stuff like wizards who dont actually give buffs but instead trigger abilities twice
		if(buff_damage_amount == 0 and buff_health_amount == 0):
			tile_when_no_unit.find_child("Sprite2D").self_modulate = Color(0.075,1,0.065,1)
			
