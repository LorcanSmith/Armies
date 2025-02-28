extends Node

#Amount of damage to do to enemy units
var damage : int
#Amount of heals to do to friendly units
var heal : int

#Does this skill belong to the player or enemy
var belongs_to_player : bool

func _on_area_2d_area_entered(area: Area2D) -> void:
	if(belongs_to_player and area.is_in_group("enemy")):
		area.hurt(damage)
	elif(!belongs_to_player and area.is_in_group("player")):
		area.heal(heal)
	queue_free()
