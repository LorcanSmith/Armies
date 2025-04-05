extends RichTextLabel

var tween

func animate():
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
