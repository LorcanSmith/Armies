extends Node

var enemy : Node2D
var enemy_position : Vector2
var current_pos
var damage : int
var enemies_in_splash_zone : Array
@export var moves : bool
@export var speed : float

var shockwave_scene = load("res://Prefabs/Effects/Projectiles/shockwave.tscn")

var distance : int

func target_enemy(unit : Node2D):
	enemy = unit
	enemy_position = unit.global_position
	current_pos = self.global_position
	distance = current_pos.distance_to(enemy_position)
	
var t = 0
func _process(delta: float) -> void:
	t += delta
	if(moves):
		#If the enemy positiion exists
		if(enemy_position):
			#Move towards it
			self.global_position = lerp(current_pos, enemy_position, t * speed)
			#If the projectile is still far away and it hasnt overshot the unit
			if(self.global_position.distance_to(enemy_position) < distance and self.global_position.distance_to(enemy_position) > 10):
				#Set the new distance remaining
				distance = self.global_position.distance_to(enemy_position)
			else:
				if(enemies_in_splash_zone):
					var counter = 0
					while counter < enemies_in_splash_zone.size():
						if enemies_in_splash_zone[counter]:
							enemies_in_splash_zone[counter].projectile_hit(damage)
						counter += 1
					$Sprite2D.visible = false
					var shockwave = shockwave_scene.instantiate()
					get_parent().add_child(shockwave)
					shockwave.position = self.position
					queue_free()
				else:
					if(enemy):
						enemy.projectile_hit(damage)
					queue_free()
	else:
		self.global_position = enemy_position
		if(enemy):
			enemy.projectile_hit(damage)
			enemy = null
		else:
			pass
	#Stops an issue where projectiles over shoot their target for some reason
	if(t > 1.5):
		queue_free()
func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
