extends Node

var waiting_for_skills : bool = false

func _process(delta: float) -> void:
	if(waiting_for_skills):
		if(self.get_child_count() == 0):
			waiting_for_skills = false
			get_parent().no_skills_left()
