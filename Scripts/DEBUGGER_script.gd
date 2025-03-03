extends Node2D

#Are you placing friendly or enemy units in the shop
var place_enemy : bool = false
var place_skill : bool = false

#Skill number  to spawn, number is gotten from the canvas "optionbutton"
var skill_to_place : int = 0
#List of skills we can spawn
@export var skills = []

func _on_place_enemy_button_toggled(toggled_on: bool) -> void:
	DebuggerScript.place_enemy = toggled_on
func _on_check_button_toggled(toggled_on: bool) -> void:
	DebuggerScript.place_skill = toggled_on


func _on_option_button_item_selected(index: int) -> void:
	skill_to_place = index

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#Checks to see if something has happened with the left mouse button
			if event.button_index == MOUSE_BUTTON_LEFT:
				if(DebuggerScript.place_skill):
					if(skills.size() > 0):
						var instance = skills[skill_to_place].instantiate()
						self.add_child(instance)
						#Tell the skill how much damage it does
						instance.belongs_to_player = false
						instance.global_position = get_global_mouse_position()
						instance.damage = 8
