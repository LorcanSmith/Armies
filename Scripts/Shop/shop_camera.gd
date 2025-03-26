extends Node

func position_camera(pos):
	self.global_position = Vector2(self.global_position.x, pos)
