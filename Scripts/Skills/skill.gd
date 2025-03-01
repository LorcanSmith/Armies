extends Node

#Amount of damage to do to enemy units
var damage : int
#Amount of heals to do to friendly units
var heal : int

#Does this skill belong to the player or enemy
var belongs_to_player : bool

func _on_area_2d_area_entered(area: Area2D) -> void:
	#If the area the skill is in belongs to the enemy and we are a friendly skill
	if(belongs_to_player and area.get_parent().is_in_group("enemy")):
		#Do damage to the enemy
		area.get_parent().hurt(damage)
	#If the area the skill is in belongs to a friendly and we are an enemy skill
	if(!belongs_to_player and area.get_parent().is_in_group("player")):
		#Do damage to the player
		area.get_parent().hurt(damage)
	queue_free()
