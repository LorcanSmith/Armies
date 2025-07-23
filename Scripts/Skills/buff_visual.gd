extends Node

var unit : Node2D
var target : Node2D
var move : bool = false
var starting_location : Vector2
#Used to determine what animation to play: health or damage
##0 == health, 1 == damage, 2 == retrigger
@export var buff_type : int = 0

var t = 0
func _process(delta: float) -> void:
	if(move and unit):
		t += delta
		#If this is a health buff, set the target to the heart sprite
		if(buff_type == 0):
			target = unit.find_child("heart_sprite")
		#If this is a damage buff, set the target to the sword sprite
		elif(buff_type == 1):
			target = unit.find_child("sword_sprite")
		elif(buff_type == 2):
			target = unit
		#Move the heart/sword sprite towards the target
		find_child("Sprite2D").global_position = lerp(starting_location, target.global_position, t*3)
		#If the sprite is close enough to the target location
		if(find_child("Sprite2D").global_position.distance_to(target.global_position) < 15):
			#Tell it to stop moving
			move = false
			#Fade out
			get_node("AnimationPlayer").play("fade_out")
			#Make the heart/sword on the unit bounce a little for visual feedback
			if(buff_type == 0):
				var anim_player = unit.get_node("AnimationPlayer")
				if(anim_player.is_playing()):
					anim_player.queue("health_bounce")
				else:
					anim_player.play("health_bounce")
			elif(buff_type == 1):
				var anim_player2 = unit.get_node("AnimationPlayer2")
				if(anim_player2.is_playing()):
					anim_player2.queue("damage_bounce")
					print(anim_player2.current_animation)
				else:
					anim_player2.play("damage_bounce")
			#Update the text on the unit health/damage label
			unit.update_label_text()

func _on_animation_player_animation_finished(anim_name : String) -> void:
	if(anim_name == "buff_appear"):
		starting_location = find_child("Sprite2D").global_position
		move = true
	if(anim_name == "fade_out"):
		queue_free()
