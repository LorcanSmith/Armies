extends Node

var starting_position_x : int

func _ready() -> void:
	starting_position_x = self.position.x

func _on_mouse_entered() -> void:
	self.position.x = starting_position_x - 10
	


func _on_mouse_exited() -> void:
	self.position.x = starting_position_x
