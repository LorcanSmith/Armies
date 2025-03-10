extends Node2D

#Are you placing friendly or enemy units in the shop
var place_enemy : bool = false
var place_skill : bool = false

var dictionary = load("res://Scripts/Units/dictionary.gd")

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
						

func create_enemy_armies():
	var turn_number = 1
	var dictionary_instance = dictionary.new()
	var base_money : int = 30
	var base_threshold : int = 7
	var money : int
	var threshold : int
	var items : Dictionary
	var units : Array
	
	var level2_percentage = 3
	var level3_percentage = 0.5
	
	var price : int
	var random_unit : int
	var grid_width : int = 1
	var grid_height : int = 1
	var width_per_turn = [3,3,3,3,4,4,4]
	var height_per_turn = [2,2,3,3,3,3,4]
	
	
#	item scenes

	while turn_number <= 14:
		
		units = []
		
		items = dictionary_instance.item_scenes.duplicate()
		
		money = base_money * turn_number
#		factor in reroll per turn
		threshold = base_threshold + 6

		
		if(width_per_turn.size() > turn_number):
			grid_width = width_per_turn[turn_number - 1]
			grid_height = height_per_turn[turn_number - 1]
		else:
			grid_width = width_per_turn[-1]
			grid_height = height_per_turn[-1]
		
		var total_units : int = grid_width * grid_height
		
		while money > threshold and units.size() <= total_units:
			random_unit = (randi_range(1,(dictionary_instance.item_scenes.size()/3))*3)
			var random_percentage = randf_range(1,100)
			var random_level
			if(random_percentage <= (level2_percentage + (4 * turn_number))):
				random_level = 2
				if(random_percentage <= level3_percentage * turn_number):
					random_level = 3
			else:
				random_level = 1
			if(random_level == 1):
				random_unit = random_unit-3
			elif(random_level == 2):
				#Gets the unit ID
				random_unit = random_unit-2
			elif(random_level == 3):
				#Gets the unit ID
				random_unit = random_unit-1
			if items.has(random_unit):
				price = items[random_unit].instantiate().buy_cost
				
				if price > money:
					items.erase(random_unit)
				else:
					money -= price
					units.append([random_unit, 0, 0])
		while units.size() < total_units:
			units.append(null)
		
		units.shuffle()
		var grid_data = []
		var counter = 0
		while counter < total_units:
			grid_data.append(units.slice(counter, counter + grid_height))
			counter += grid_height
		var game_folder = ProjectSettings.globalize_path("res://")
		
		var	grid_name = "enemy"
		
		var current_turn_number = "turn" + str(turn_number)
		
		var json_string
		
		var file_path = game_folder + grid_name + current_turn_number + ".save"
		var save_file
		if FileAccess.file_exists(file_path):
			#This will give you the project directory.
			save_file = FileAccess.open(file_path, FileAccess.READ_WRITE)
			# Move the file cursor to the end of the file (just in case it's not already there)
			save_file.seek_end()
		else:
			save_file = FileAccess.open(file_path, FileAccess.WRITE)
		# JSON provides a static method to serialize the grid_data to a string
		json_string = JSON.stringify(grid_data)
		#print(json_string)
		# Store the save data as a new line in the save file
		save_file.store_line(json_string)
		save_file.close()  # Don't forget to close the file after you're done.
		
		turn_number += 1
