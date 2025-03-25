extends Node

var target : Node2D
var move : bool = false
var starting_location : Vector2

var t = 0
func _process(delta: float) -> void:
	if(move):
		t += delta
		self.global_position = lerp(starting_location, target.global_position, t*3)
		if(self.global_position.distance_to(target.global_position) < 1):
			move = false
			get_node("AnimationPlayer").play("fade_out")


func _on_animation_player_animation_finished(anim_name : String) -> void:
	if(anim_name == "buff_appear"):
		starting_location = self.global_position
		move = true
	if(anim_name == "fade_out"):
		queue_free()
