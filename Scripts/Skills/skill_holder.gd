extends Node

#This node holds all skills. We do this so we can keep track of when all skills have
#finished and the game should proceed with applying damage

#Are we waiting for skills to finish
var waiting_for_skills : bool = false

func _process(delta: float) -> void:
	print(get_children())
	if(waiting_for_skills):
		#If we have no children it means there are no more skills to wait for
		if(self.get_child_count() == 0):
			waiting_for_skills = false
			#Tell the combat manager to proceed with combat
			get_parent().no_skills_left()
