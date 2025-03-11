extends Node

var enemy : Node2D
var enemy_position : Vector2
var current_pos
@export var speed : float
func target_enemy(unit : Node2D):
	enemy = unit
	enemy_position = unit.global_position
	current_pos = self.global_position
var t = 0
func _process(delta: float) -> void:
	t += delta
	#If the enemy positiion exists
	if(enemy_position):
		#Move towards it
		self.global_position = lerp(current_pos, enemy_position, t * speed)
		#If the projectile is close by delete it and apply damage to enemy
		if(self.global_position.distance_to(enemy_position) < 1):
			if(enemy):
				enemy.apply_damage()
			queue_free()
	#Makes sure the projectile hasnt flown off into the distance, if it has, it deletes it
	if(t > 2):
		queue_free()
