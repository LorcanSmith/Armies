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

var game_manager : Node2D

var reroll_UI : CanvasLayer

var remove_units_UI : CanvasLayer

var unit_themes : Array = [
	"Medieval",
	"Army",
	"Dinosaur",
	"Fantasy"
	]

#Loads new units and then shows new units in the shop
func _ready() -> void:
	game_manager = find_parent("game_manager")
	reroll_UI = find_child("reroll_UI")
	remove_units_UI = find_child("remove_units_UI")
	level2_percentage = (level2_percentage + game_manager.higher_level_unit_chance) /100
	level3_percentage = (level3_percentage + game_manager.higher_level_unit_chance) /100
	print("lvl2: ", level2_percentage, ", lvl3: ", level3_percentage)
	#Gets the children and sets them as locations units can spawn at
	var counter = 0
	var location
	while (counter < game_manager.shop_slots):
		counter += 1
		location = find_child("unit" + str(counter))
		unit_locations.append(location)
	for loc in find_child("booster_locations").get_children():
		booster_locations.append(loc)
	update_upgrade_cost_labels()

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
			
			#Tells it, what crate number it is for "randomness"
			new_booster.select_units(x)
			#Sets the new units' location to be that of its parent (the shop unit location)
			new_booster.position = Vector2(0,0)
		x+=1
#Chooses a random unit
func choose_random_unit(loc : int):
	var dictionary_instance = dictionary.new()
	seed((loc + 1) * (rerolls_taken + 1) * find_parent("game_manager").seed * find_parent("game_manager").turn_number)
	var percentage
	var random_unit_percentage
	var random_unit
	var random_unit_position
	var random_level
	var loaded_unit
	var unit_not_found = true
	
	while unit_not_found:
		percentage = randf_range(0,100)/100
		random_unit_percentage = randf_range(0,100)/100
		random_unit = int(((dictionary_instance.item_scenes.size()/3) * random_unit_percentage))
		random_unit_position = random_unit*3
		if(percentage <= level2_percentage):
			if(percentage <= level3_percentage):
				random_level = 3
			else:
				random_level = 2
		else:
			random_level = 1
		if(random_level == 2):
			#Gets the unit ID
			random_unit_position += 1
		elif(random_level == 3):
			#Gets the unit ID
			random_unit_position += 2
		var unit = dictionary_instance.unit_scenes[random_unit_position].instantiate()
		var x = 0
		var types = []
	#	only set to false if player removed a unit from the shop pool
		var unit_allowed = true
		while(x < game_manager.blocked_types.size()):
			#Finds the boolean with the same name as unit_types[x]
			var type = unit.get(game_manager.blocked_types[x])
			if(type):
				unit_allowed = false
				break
			x += 1
		if unit_allowed:
			loaded_unit = dictionary_instance.item_scenes[random_unit_position]
			unit_not_found = false
	return [loaded_unit, random_unit_position]
	
func choose_random_booster(loc : int):
	var dictionary_instance = dictionary.new()
	seed(find_parent("game_manager").seed * (1+loc) * (rerolls_taken+1))
	var booster_not_found = true
	var booster_instance
	var booster
	while booster_not_found:
		var random_booster_percentage = randf_range(0,100)/100
		#Gets a random unit type
		
		var random_booster = int(round((dictionary_instance.booster_scenes.size()-1) * random_booster_percentage))
		booster_instance = dictionary_instance.booster_scenes[random_booster].instantiate()
		var booster_name = booster_instance.booster_name
		
		#if booster_instance.booster_name.contains
		var x = 0
		var booster_allowed = true
		while(x < game_manager.blocked_types.size()):
			if(booster_name.contains(game_manager.blocked_types[x])):
				booster_allowed = false
				break
			x += 1
		if booster_allowed:
			booster = dictionary_instance.booster_scenes[random_booster]
			booster_not_found = false
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

func _on_reroll_button_pressed():
	reroll_shop()

func _on_unit_chance_button_pressed():
	var success = false
	if !(find_parent("shop_manager").free_reroll):
		if (((game_manager.shop_upgrades + 1) * 5)  <= find_parent("shop_manager").money):
			success = true
			find_parent("shop_manager").change_money(((game_manager.shop_upgrades + 1) * 5) - find_parent("shop_manager").reroll_cost)
	else:
		success = true
	if success:
		reroll_UI.visible = false
		game_manager.higher_level_unit_chance += 1
		game_manager.shop_upgrades += 1
		update_upgrade_cost_labels()
		reroll_shop()

func _on_shop_slot_button_pressed():
	var success = false
	if !(find_parent("shop_manager").free_reroll):
		if (((game_manager.shop_upgrades + 1) * 5)  <= find_parent("shop_manager").money):
			success = true
			find_parent("shop_manager").change_money(((game_manager.shop_upgrades + 1) * 5) - find_parent("shop_manager").reroll_cost)
	else:
		success = true
	if success:
		reroll_UI.visible = false
		game_manager.shop_slots += 1
		unit_locations.append(find_child("unit" + str(game_manager.shop_slots)))
		find_child("pedestal" + str(game_manager.shop_slots)).visible = true
		game_manager.shop_upgrades += 1
		update_upgrade_cost_labels()
		reroll_shop()


func _on_upgrade_button_pressed():
	reroll_UI.visible = true


func _on_close_button_pressed():
	reroll_UI.visible = false
	
func update_upgrade_cost_labels():
	var counter = 4
	while (counter < game_manager.shop_slots):
		counter += 1
		find_child("pedestal" + str(counter)).visible = true
	find_child("unit_chance_cost").text = str((game_manager.shop_upgrades + 1) * 5)
	if game_manager.shop_slots < game_manager.MAX_SHOP_SLOTS:
		find_child("shop_slot_cost").text = str((game_manager.shop_upgrades + 1) * 5)
	else:
		find_child("shop_slot_cost").text = "X"
		find_child("shop_slot_button_text").text = "FULL"
		find_child("shop_slot_button").disabled = true
	counter = 0
	var theme
	while counter < unit_themes.size():
		theme = unit_themes[counter].to_lower()
		if game_manager.blocked_types.has(unit_themes[counter]):
			find_child("remove_{theme}_cost".format({"theme": theme})).text = "X"
			find_child("remove_{theme}_button_text".format({"theme": theme})).text = "REMOVED"
			find_child("remove_{theme}_button".format({"theme": theme})).disabled = true
		else:
			find_child("remove_{theme}_cost".format({"theme": theme})).text = str((game_manager.shop_upgrades + 1) * 5)
		counter += 1
	

func _on_remove_units_button_pressed():
	reroll_UI.visible = false
	remove_units_UI.visible = true


func _on_remove_UI_close_button_pressed():
	remove_units_UI.visible = false
	reroll_UI.visible = true


func _on_remove_medieval_button_pressed():
	var success = false
	if !(find_parent("shop_manager").free_reroll):
		if (((game_manager.shop_upgrades + 1) * 5)  <= find_parent("shop_manager").money):
			success = true
			find_parent("shop_manager").change_money(((game_manager.shop_upgrades + 1) * 5) - find_parent("shop_manager").reroll_cost)
	else:
		success = true
	if success:
		remove_units_UI.visible = false
		game_manager.blocked_types.append("Medieval")
		game_manager.shop_upgrades += 1
		update_upgrade_cost_labels()
		reroll_shop()


func _on_remove_army_button_pressed():
	var success = false
	if !(find_parent("shop_manager").free_reroll):
		if (((game_manager.shop_upgrades + 1) * 5)  <= find_parent("shop_manager").money):
			success = true
			find_parent("shop_manager").change_money(((game_manager.shop_upgrades + 1) * 5) - find_parent("shop_manager").reroll_cost)
	else:
		success = true
	if success:
		remove_units_UI.visible = false
		game_manager.blocked_types.append("Army")
		game_manager.shop_upgrades += 1
		update_upgrade_cost_labels()
		reroll_shop()


func _on_remove_dinosaur_button_pressed():
	var success = false
	if !(find_parent("shop_manager").free_reroll):
		if (((game_manager.shop_upgrades + 1) * 5)  <= find_parent("shop_manager").money):
			success = true
			find_parent("shop_manager").change_money(((game_manager.shop_upgrades + 1) * 5) - find_parent("shop_manager").reroll_cost)
	else:
		success = true
	if success:
		remove_units_UI.visible = false
		game_manager.blocked_types.append("Dinosaur")
		game_manager.shop_upgrades += 1
		update_upgrade_cost_labels()
		reroll_shop()


func _on_remove_fantasy_button_pressed():
	var success = false
	if !(find_parent("shop_manager").free_reroll):
		if (((game_manager.shop_upgrades + 1) * 5)  <= find_parent("shop_manager").money):
			success = true
			find_parent("shop_manager").change_money(((game_manager.shop_upgrades + 1) * 5) - find_parent("shop_manager").reroll_cost)
	else:
		success = true
	if success:
		remove_units_UI.visible = false
		game_manager.blocked_types.append("Fantasy")
		game_manager.shop_upgrades += 1
		update_upgrade_cost_labels()
		reroll_shop()
