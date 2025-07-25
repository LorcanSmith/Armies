extends Node

var close_in_secs : float = 2
var countdown : bool = false

var starting_scale : Vector2 = Vector2(1,1)

var mouse_over : bool = false
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "pop_out"):
		queue_free()


func _on_bg_mouse_exited() -> void:
	countdown = true
	self.scale = starting_scale
	mouse_over = false

func _on_bg_mouse_entered() -> void:
	countdown = false
	close_in_secs = 1.5
	self.scale = starting_scale * 1.1
	mouse_over = true

func _process(delta: float) -> void:
	if(countdown):
		close_in_secs -= delta
		if(close_in_secs <= 0):
			self.get_node("AnimationPlayer").play("pop_out")


func _on_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		#Checks to see if something has happened with the left mouse button
		if(event.button_index == MOUSE_BUTTON_LEFT and mouse_over):
			self.get_node("AnimationPlayer").play("pop_out")
