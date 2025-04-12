extends Node

#Places where shop units show up
var unit_locations = []
#Places where boosters show up
var booster_locations = []
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
	for loc in find_child("booster_locations").get_children():
		booster_locations.append(loc)
#Spawns in new shop units
func show_new_units():
	var x = 0
	#Displays a new unit for each shop unit location
	while x < unit_locations.size():
		#Chooses a random unit and loads the unit from the path, gets it unit_ID
		var chosen_unit = choose_random_unit(x)
		#Spawns in the chosen unit as a new unit in the shop
		var new_unit = chosen_unit[0].instantiate()
		new_unit.unit_ID = chosen_unit[1]
		#Sets the new units' parent to be the unit location in the shop
		unit_locations[x].add_child(new_unit)
		#Sets the new units' location to be that of its parent (the shop unit location)
		new_unit.position = Vector2(0,0)
		x+=1
	for location in booster_locations.size():
		#If there isnt a unit from a previous pack in the slot
		if(booster_locations[location].get_child_count() == 0 or booster_locations[location].get_child(0).is_in_group("booster")):
			#Chooses a random unit and loads the unit from the path, gets it unit_ID
			var chosen_booster = choose_random_booster()
			#Spawns in the chosen unit as a new unit in the shop
			var new_booster = chosen_booster.instantiate()
			#Sets the new units' parent to be the unit location in the shop
			booster_locations[location].add_child(new_booster)
			#Sets the new units' location to be that of its parent (the shop unit location)
			new_booster.position = Vector2(0,0)
#Chooses a random unit
func choose_random_unit(loc : int):
	var dictionary_instance = dictionary.new()
	var x = loc
	#
	while(x > find_parent("shop_manager").seed.size()-1):
		x -= find_parent("shop_manager").seed.size()-1
	var seed_number_as_percentage = float(find_parent("shop_manager").seed[x])/100
	var random_unit_position = int(round(((dictionary_instance.item_scenes.size()/3)*3) * seed_number_as_percentage))
	var random_level
	if(seed_number_as_percentage <= level2_percentage):
		random_level = 2
		if(seed_number_as_percentage <= level3_percentage):
			random_level = 3
	else:
		random_level = 1
	var loaded_unit
	if(random_level == 1):
		random_unit_position -= 3
		loaded_unit = dictionary_instance.item_scenes[random_unit_position]
	elif(random_level == 2):
		#Gets the unit ID
		random_unit_position -= 2
		loaded_unit = dictionary_instance.item_scenes[random_unit_position]
	elif(random_level == 3):
		#Gets the unit ID
		random_unit_position -= 1
		loaded_unit = dictionary_instance.item_scenes[random_unit_position]
	#print(random_unit)
	return [loaded_unit, random_unit_position]
	
func choose_random_booster():
	var dictionary_instance = dictionary.new()
	#Gets a random unit type
	var random_booster = randi_range(0,(dictionary_instance.booster_scenes.size())-1)
	
	
	
	var booster = dictionary_instance.booster_scenes[random_booster]
	return booster
	
func reroll_shop():
	#Remove old shop units before showing new units
	#The units are parented to the shop location they are at, so we loop over every
	#shop location and delete their child
	var reroll_success = false
	if !(find_parent("shop_manager").free_reroll):
		if (find_parent("shop_manager").reroll_cost <= find_parent("shop_manager").money):
			find_parent("shop_manager").change_money(find_parent("shop_manager").reroll_cost)
			reroll_success = true
	else:
		reroll_success = true
	if reroll_success:
		var location = 0
		while location < unit_locations.size():
			#If it doesn't have a child no need to delete the child, this if statement
			#stops crashes
			if(unit_locations[location].get_child_count() > 0):
				unit_locations[location].get_child(0).queue_free()
			location += 1
		location = 0
		while location < booster_locations.size():
			if(booster_locations[location].get_child_count() > 0 and booster_locations[location].get_child(0).is_in_group("booster")):
				booster_locations[location].get_child(0).queue_free()
			location += 1
		#Gets new units for the shop
		show_new_units()
	

func _on_texture_button_pressed() -> void:
	reroll_shop()
