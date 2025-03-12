extends Node

#This node holds all skills. We do this so we can keep track of when all skills have
#finished and the game should proceed with applying damage

#Are we waiting for skills to finish
var waiting_for_skills : bool = false

#Delays are so they skill holder doesnt say its empty whilst skills are still being spawned in
var delay = 0.3
var current_delay = 0.3
func _process(delta: float) -> void:
	if(waiting_for_skills):
		current_delay -= delta
		#If we have no children it means there are no more skills to wait for
		if(current_delay <= 0 and self.get_child_count() == 0):
			waiting_for_skills = false
			current_delay = delay
			#Tell the combat manager to proceed with combat
			get_parent().no_skills_left()
