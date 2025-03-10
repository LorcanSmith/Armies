extends Node


func _on_animation_finished() -> void:
	queue_free()
