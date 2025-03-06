extends Node

#Amount of damage to do to enemy units
var damage : int
#Amount of heals to do to friendly units
var heal : int

var pushes_units : bool

#Does this skill belong to the player or enemy
var belongs_to_player : bool

var effective_against : Array = []
var effectiveness : int
func _on_area_2d_area_entered(area: Area2D) -> void:
	#ENEMY! DO DAMAGE
	if((belongs_to_player and area.get_parent().is_in_group("enemy")) or (!belongs_to_player and area.get_parent().is_in_group("player")) and (!area.is_in_group("buff_location"))):
		var effective = false
		if(!area.get_parent().is_in_group("headquarter")):
			for type in effective_against:
				if(type != null and area.get_parent().unit_types.has(type)):
					effective = true
			if(effective):
				#Do damage to the enemy
				area.get_parent().hurt(damage + effectiveness)
			else:
				area.get_parent().hurt(damage)
		else:
			area.get_parent().hurt(damage)
	#FRIENDLY DO HEALS
	if((belongs_to_player and area.get_parent().is_in_group("player")) or (!belongs_to_player and area.get_parent().is_in_group("enemy")) and (!area.is_in_group("buff_location"))):
		var effective = false
		if(!area.get_parent().is_in_group("headquarter")):
			for type in effective_against:
				if(type != null and area.get_parent().unit_types.has(type)):
					effective = true
			if(effective):
				#Do damage to the enemy
				area.get_parent().heal(heal + effectiveness)
			else:
				area.get_parent().heal(heal)
		else:
			area.get_parent().hurt(damage)
		##DEBUG
		#Allows us to do damage to units straight away without waiting for the ticker
		#used for testing skills
		if(DebuggerScript.place_skill):
			area.get_parent().apply_damage()
	queue_free()
