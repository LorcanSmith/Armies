extends Node

var starting_size : float

@export var expanding_amount : float = 1.1

func _ready() -> void:
	starting_size = self.scale.x

func _on_mouse_entered() -> void:
	self.scale = Vector2(starting_size * expanding_amount, starting_size * expanding_amount)

func _on_mouse_exited() -> void:
	self.scale = Vector2(starting_size, starting_size)
