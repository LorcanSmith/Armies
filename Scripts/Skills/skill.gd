extends Node

#Amount of damage to do to enemy units
var damage : int
#Amount of heals to do to friendly units
var heal : int

var projectile : PackedScene
var target : Node2D

var target_is_friendly : bool

var enemies_in_splash_zone
var skill_does_splash : bool
#Does this skill belong to the player or enemy
var belongs_to_player : bool
var owner_of_skill : Node2D
var effective_against : Array = []
var effectiveness : int

var spawned_visual_already : bool
func _process(delta):
	await get_tree().create_timer(.1).timeout
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	#ENEMY! DO DAMAGE
	if((belongs_to_player and area.get_parent().is_in_group("enemy")) or (!belongs_to_player and area.get_parent().is_in_group("player")) and (!area.is_in_group("buff_location"))):
		var effective = false
		if(!area.get_parent().is_in_group("headquarter")):
			if (!area.get_parent().no_weaknesses):
				for type in effective_against:
					if(type != null and area.get_parent().unit_types.has(type)):
						effective = true
			if(effective):
				#Do damage to the enemy
				damage = damage * 2
				target.hurt(damage)
				if(!spawned_visual_already):
					attack_visuals()
					spawned_visual_already = true
			else:
				target.hurt(damage)
				if(!spawned_visual_already):
					attack_visuals()
					spawned_visual_already = true
		else:
			target.hurt(damage)
			if(!spawned_visual_already):
				attack_visuals()
				spawned_visual_already = true
	#FRIENDLY DO HEALS
	if((belongs_to_player and area.get_parent().is_in_group("player")) or (!belongs_to_player and area.get_parent().is_in_group("enemy")) and (!area.is_in_group("buff_location"))):
		print("area: ", area.get_parent(), ", self: ", self, ", owner: ", owner_of_skill)
		var effective = false
		target_is_friendly = true
		if(!area.get_parent().is_in_group("headquarter")):
			for type in effective_against:
				if(type != null and area.get_parent().unit_types.has(type)):
					effective = true
			if(effective):
				heal = heal*2
				#Do heal to friendly
				target.heal(heal)
				if(!spawned_visual_already):
					attack_visuals()
					spawned_visual_already = true
			else:
				target.heal(heal)
				if(!spawned_visual_already):
					attack_visuals()
					spawned_visual_already = true
	

func attack_visuals():
	var projectile_instance = projectile.instantiate()
	find_parent("combat_manager").find_child("skill_holder").add_child(projectile_instance)
	projectile_instance.global_position = owner_of_skill.global_position
	if(!target_is_friendly):
		projectile_instance.damage = damage
	if(target_is_friendly):
		projectile_instance.damage = -heal
	if skill_does_splash:
		projectile_instance.enemies_in_splash_zone = enemies_in_splash_zone
	projectile_instance.target_enemy(target)
	queue_free()
