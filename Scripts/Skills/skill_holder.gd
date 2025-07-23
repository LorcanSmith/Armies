extends Node

#This node holds all skills. We do this so we can keep track of when all skills have
#finished and the game should proceed with applying damage

#If set to true, the skill holder/buff holder will stop all process
var pause_checks : bool = false
#Are we waiting for skills to finish
var waiting_for_skills : bool = false
var waiting_for_deaths : bool = true
#Delays are so they skill holder doesnt say its empty whilst skills are still being spawned in
@export var delay = 0.4
var current_delay = 0.3

func _ready() -> void:
	current_delay = delay
func _process(delta: float) -> void:
	if(!pause_checks):
		if(waiting_for_skills):
			current_delay -= delta
			#If we have no children it means there are no more skills to wait for
			if(current_delay <= 0 and self.get_child_count() == 0):
				waiting_for_skills = false
				current_delay = delay
				if(self.name == "skill_holder"):
					#Tell the combat manager to proceed with combat
					get_parent().no_skills_left()
				elif(self.name == "buff_animation_holder"):
					waiting_for_deaths = false
					#Tell shop_manager to kill any units required
					get_parent().kill_units()
			elif(current_delay <= 0 and self.get_child_count() > 0):
				current_delay = delay
		if(!waiting_for_deaths and !waiting_for_skills):
			current_delay -= delta
			#If we have no children it means there are no more skills to wait for
			if(current_delay <= 0 and self.get_child_count() == 0):
				current_delay = delay
				#Tells skill holder to pause so we can transition scene
				pause_checks = true
				#Tell the shop manager to proceed with combat
				await get_tree().create_timer(0.5).timeout
				get_parent().no_skills_left()
			elif(current_delay <= 0 and self.get_child_count() > 0):
				current_delay = delay
