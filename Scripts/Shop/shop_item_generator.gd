extends Node

#Places where shop units show up
var unit_locations = []
#Dictionary containing all units
var dictionary = load("res://Scripts/Units/dictionary.gd")

##Percentage out of 100 for how likely a level 2 unit is to show up
@export var level2_percentage = 7
@export var level3_percentage = 0.5
##Percentage out of 100 for how likely a level 3 unit is to show up
#Loads new units and then shows new units in the shop
func _ready() -> void:
	#Gets the children and sets them as locations units can spawn at
	for loc in find_child("Unit Locations").get_children():
		unit_locations.append(loc)
	show_new_units()
#Spawns in new shop units
func show_new_units():
	#Displays a new unit for each shop unit location
	for location in unit_locations.size():
		#Chooses a random unit and loads the unit from the path, gets it unit_ID
		var chosen_unit = choose_random_unit()
		#Spawns in the chosen unit as a new unit in the shop
		var new_unit = chosen_unit[0].instantiate()
		new_unit.unit_ID = chosen_unit[1]
		#Sets the new units' parent to be the unit location in the shop
		unit_locations[location].add_child(new_unit)
		#Sets the new units' location to be that of its parent (the shop unit location)
		new_unit.position = Vector2(0,0)
			
#Chooses a random unit
func choose_random_unit():
	var dictionary_instance = dictionary.new()
	#Gets a random unit type
	var random_unit = (randi_range(1,(dictionary_instance.item_scenes.size()/3))*3)
	#Gets a random number
	var random_percentage = randf_range(1,100)
	var random_level
	if(random_percentage <= level2_percentage):
		random_level = 2
		if(random_percentage <= level3_percentage):
			random_level = 3
	else:
		random_level = 1
	var loaded_unit
	if(random_level == 1):
		random_unit = random_unit-3
		loaded_unit = dictionary_instance.item_scenes[random_unit]
	elif(random_level == 2):
		#Gets the unit ID
		random_unit = random_unit-2
		loaded_unit = dictionary_instance.item_scenes[random_unit]
	elif(random_level == 3):
		#Gets the unit ID
		random_unit = random_unit-1
		loaded_unit = dictionary_instance.item_scenes[random_unit]
	#print(random_unit)
	return [loaded_unit, random_unit]
	
func choose_random_boost():
	var dictionary_instance = dictionary.new()
	#Gets a random unit type
	var random_boost = randi_range(0,(dictionary_instance.boost_scenes.size())-1)
	var boost = dictionary_instance.boost_scenes[random_boost]
	return boost
func reroll_shop():
	#Remove old shop units before showing new units
	#The units are parented to the shop location they are at, so we loop over every
	#shop location and delete their child
	var reroll_success = false
	if !get_parent().free_reroll:
		if get_parent().reroll_cost <= get_parent().money:
			get_parent().change_money(get_parent().reroll_cost)
			reroll_success = true
	else:
		reroll_success = true
	if reroll_success:
		for location in unit_locations:
			#If it doesn't have a child no need to delete the child, this if statement
			#stops crashes
			if(location.get_child_count() > 0):
				location.get_child(0).queue_free()
		#Gets new units for the shop
		show_new_units()
	

func _on_texture_button_pressed() -> void:
	reroll_shop()
