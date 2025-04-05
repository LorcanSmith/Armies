extends Node

var unit : Node2D
var target : Node2D
var move : bool = false
var starting_location : Vector2
#Used to determine what animation to play: health or damage
@export var this_is_health_buff : bool

var t = 0
func _process(delta: float) -> void:
	if(move):
		t += delta
		#If this is a health buff, set the target to the heart sprite
		if(this_is_health_buff):
			target = unit.find_child("heart_sprite")
		#If this is a damage buff, set the target to the sword sprite
		else:
			target = unit.find_child("sword_sprite")
		#Move the heart/sword sprite towards the target
		find_child("Sprite2D").global_position = lerp(starting_location, target.global_position, t*3)
		#If the sprite is close enough to the target location
		if(find_child("Sprite2D").global_position.distance_to(target.global_position) < 15):
			#Tell it to stop moving
			move = false
			#Fade out
			get_node("AnimationPlayer").play("fade_out")
			#Make the heart/sword on the unit bounce a little for visual feedback
			if(this_is_health_buff):
				unit.get_node("AnimationPlayer").play("health_bounce")
			else:
				unit.get_node("AnimationPlayer2").play("damage_bounce")
			#Update the text on the unit health/damage label
			unit.update_label_text()

func _on_animation_player_animation_finished(anim_name : String) -> void:
	if(anim_name == "buff_appear"):
		starting_location = find_child("Sprite2D").global_position
		move = true
	if(anim_name == "fade_out"):
		queue_free()
