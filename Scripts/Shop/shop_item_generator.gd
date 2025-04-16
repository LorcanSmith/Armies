extends Node

#Places where shop units show up
var unit_locations = []
#Places where boosters show up
var booster_locations = []
#Dictionary containing all units
var dictionary = load("res://Scripts/Units/dictionary.gd")
#Amount of re-rolls taken, used for randomness
var rerolls_taken : int = 0
##Percentage out of 100 for how likely a level 2 unit is to show up
@export var level2_percentage : float = 7
@export var level3_percentage : float = 0.5
##Percentage out of 100 for how likely a level 3 unit is to show up
#Loads new units and then shows new units in the shop
func _ready() -> void:
	level2_percentage = level2_percentage/100
	level3_percentage = level3_percentage/100
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
		new_unit.bought = false
		new_unit.unit_ID = chosen_unit[1]
		#Sets the new units' parent to be the unit location in the shop
		unit_locations[x].add_child(new_unit)
		#Sets the new units' location to be that of its parent (the shop unit location)
		new_unit.position = Vector2(0,0)
		x+=1
	x = 0
	while x < booster_locations.size():
		#If there isnt a unit from a previous pack in the slot
		if(booster_locations[x].get_child_count() == 0 or booster_locations[x].get_child(0).is_in_group("booster")):
			#Chooses a random unit and loads the unit from the path, gets it unit_ID
			var chosen_booster = choose_random_booster(x)
			#Spawns in the chosen unit as a new unit in the shop
			var new_booster = chosen_booster.instantiate()
			#Sets the new units' parent to be the unit location in the shop
			booster_locations[x].add_child(new_booster)
			
			var seed : Array = find_parent("shop_manager").seed
			var reversed_seed : Array = seed.duplicate()
			var new_seed : Array
			reversed_seed.reverse()
			#Multiply each element by its reveresed element in the seed and then make sure its not above 100
			var num = 0
			while(num < seed.size()-1):
				new_seed.append(seed[num] * reversed_seed[num] * (rerolls_taken+1))
				while(new_seed[num] > 100):
					new_seed[num] -= 100
				num+=1
			#Tells it, what crate number it is for "randomness"
			new_booster.select_units(x * (rerolls_taken+1), new_seed)
			#Sets the new units' location to be that of its parent (the shop unit location)
			new_booster.position = Vector2(0,0)
		x+=1
#Chooses a random unit
func choose_random_unit(loc : int):
	var dictionary_instance = dictionary.new()
	var x = loc
	while(x > find_parent("shop_manager").seed.size()-1):
		x -= find_parent("shop_manager").seed.size()-1
	#Multiply each element by its reveresed element in the seed and then make sure its not above 100
	var num = 0
	var seed : Array = find_parent("shop_manager").seed
	var reversed_seed : Array = seed.duplicate()
	var new_seed : Array
	reversed_seed.reverse()
	var percentage = reversed_seed[x] * (rerolls_taken+1)
	while(percentage > 100):
		percentage -= 100
	while(num < seed.size()-1):
		new_seed.append(seed[num] * reversed_seed[num] * (rerolls_taken+1))
		while(new_seed[num] > 100):
			new_seed[num] -= 100
		num+=1
	var seed_number_as_percentage = float(new_seed[x])/100
	var random_unit = int(floor((((dictionary_instance.item_scenes.size())/3)) * seed_number_as_percentage))
	var random_unit_position = random_unit*3
	var random_level
	#print("Random Unit: ", random_unit)
	#print("Position: ", random_unit_position)
	#print("Percentage: ", percentage)
	if(percentage <= level2_percentage):
		random_level = 2
		if(percentage <= level3_percentage):
			random_level = 3
	else:
		random_level = 1
	var loaded_unit
	if(random_level == 1):
		loaded_unit = dictionary_instance.item_scenes[random_unit_position]
	elif(random_level == 2):
		#Gets the unit ID
		random_unit_position += 1
		loaded_unit = dictionary_instance.item_scenes[random_unit_position]
	elif(random_level == 3):
		#Gets the unit ID
		random_unit_position += 2
		loaded_unit = dictionary_instance.item_scenes[random_unit_position]
	#print(random_unit)
	return [loaded_unit, random_unit_position]
	
func choose_random_booster(loc : int):
	var dictionary_instance = dictionary.new()
	var x = loc
	while(x > find_parent("shop_manager").seed.size()-1):
		x -= find_parent("shop_manager").seed.size()-1
	#Multiply each element by its reveresed element in the seed and then make sure its not above 100
	var num = 0
	var seed : Array = find_parent("shop_manager").seed
	var reversed_seed : Array = seed.duplicate()
	var new_seed : Array
	reversed_seed.reverse()
	var percentage = reversed_seed[x] * (rerolls_taken+1)
	while(percentage > 100):
		percentage -= 100
	while(num < seed.size()-1):
		new_seed.append(seed[num] * reversed_seed[num] * (rerolls_taken+1))
		while(new_seed[num] > 100):
			new_seed[num] -= 100
		num+=1
	var seed_number_as_percentage = float(new_seed[x])/100
	#Gets a random unit type
	var random_booster = int(round((dictionary_instance.booster_scenes.size()-1) * seed_number_as_percentage))
	
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
		rerolls_taken += 1
		show_new_units()

func _on_texture_button_pressed() -> void:
	reroll_shop()
