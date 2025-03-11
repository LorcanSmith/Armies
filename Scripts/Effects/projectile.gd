extends Node

var enemy : Node2D
var enemy_position : Vector2
var current_pos
@export var moves : bool
@export var speed : float
func target_enemy(unit : Node2D):
	enemy = unit
	enemy_position = unit.global_position
	current_pos = self.global_position
	
var t = 0
func _process(delta: float) -> void:
	t += delta
	if(moves):
		#If the enemy positiion exists
		if(enemy_position):
			#Move towards it
			self.global_position = lerp(current_pos, enemy_position, t * speed)
			#If the projectile is close by delete it and apply damage to enemy
			if(self.global_position.distance_to(enemy_position) < 1):
				if(enemy):
					enemy.projectile_hit()
				queue_free()
	else:
		self.global_position = enemy_position
	##Makes sure the projectile hasnt flown off into the distance, if it has, it deletes it
	if(t > 1):
		queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	if(enemy):
		enemy.projectile_hit()
	queue_free()
