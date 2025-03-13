extends Node


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	self.get_parent().auto_tick()
