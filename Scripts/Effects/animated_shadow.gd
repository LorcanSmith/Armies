extends AnimatedSprite2D
var shadow : AnimatedSprite2D

func _ready():
	shadow = get_child(0)
	if shadow:
		shadow.sprite_frames = sprite_frames  # Share the same animation resource
func _process(delta):
	if shadow:
		shadow.animation = animation
		shadow.frame = frame
		shadow.flip_h = flip_h
