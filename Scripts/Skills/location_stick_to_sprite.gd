extends Node

var sprite : Node2D

func _ready() -> void:
	sprite = get_parent().find_child("Sprite2D")

func _process(delta: float) -> void:
	if(sprite):
		self.global_position = sprite.global_position
