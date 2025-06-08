extends Sprite2D

func _ready():
	change_shadow()

func change_shadow():
	self.texture = get_parent().texture
