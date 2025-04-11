extends Node

var coin_target : Vector2

var starting_location : Vector2

var distance : float
var move : bool
func _ready() -> void:
	coin_target = find_parent("shop_manager").find_child("coin_pos").global_position
var t = 0
func _process(delta: float) -> void:
	if(coin_target and move):
		if(self.global_position.distance_to(coin_target) <= distance):
			distance = self.global_position.distance_to(coin_target)
			t+=delta
			#Move the coin sprite towards the coin UI
			self.global_position = lerp(starting_location, coin_target, t)
		elif(self.global_position.distance_to(coin_target) > distance or distance <= 10):
			find_parent("game_manager").find_child("UI_AnimationPlayer").play("coin_bounce")
			#Gives the player money for selling an item
			find_parent("shop_manager").change_money(-1)
			queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "coin_appear"):
		starting_location = self.global_position
		distance = starting_location.distance_to(coin_target)
		move = true
