extends Node

#Amount of damage to do to enemy units
var damage : int

var projectile : PackedScene

var projectile_spawn_location : Node2D

var target : Node2D

var target_is_friendly : bool

#How long should the skill wait before doing the damage (how long does the animation take)
var anim_time : float = 0
#Does this skill belong to the player or enemy
var belongs_to_player : bool
var owner_of_skill : Vector2

var spawned_visual_already : bool

var t = 1
func _process(delta: float) -> void:
	t -= delta
	if(t <= 0):
		if(!target):
			queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	#ENEMY! DO DAMAGE
	if((belongs_to_player and area.get_parent().is_in_group("enemy")) or (!belongs_to_player and area.get_parent().is_in_group("player")) and (!area.is_in_group("buff_location"))):
		if(!area.get_parent().is_in_group("headquarter")):
			target.hurt(damage)
			if(!spawned_visual_already):
				attack_visuals()
				spawned_visual_already = true
		else:
			target.hurt(damage)
			if(!spawned_visual_already):
				attack_visuals()
				spawned_visual_already = true
func attack_visuals():
	await get_tree().create_timer(anim_time).timeout
	var projectile_instance = projectile.instantiate()
	find_parent("combat_manager").find_child("skill_holder").add_child(projectile_instance)
	if(projectile_spawn_location):
		projectile_instance.global_position = projectile_spawn_location.global_position
	elif(!projectile_spawn_location):
		projectile_instance.global_position = owner_of_skill
	if(!target_is_friendly):
		projectile_instance.damage = damage
	if(target):
		projectile_instance.target_enemy(target)
	queue_free()
