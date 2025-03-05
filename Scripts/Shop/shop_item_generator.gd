extends Node

#Places where shop items show up
var item_locations = []

#Dictionary containing all units
var dictionary = load("res://Scripts/Units/dictionary.gd")

##Percentage out of 100 for how likely a level 2 unit is to show up
@export var level2_percentage = 7
@export var level3_percentage = 0.5
##Percentage out of 100 for how likely a level 3 unit is to show up
#Loads new items and then shows new items in the shop
func _ready() -> void:
	#Gets the children and sets them as locations items can spawn at
	for loc in self.get_children():
		item_locations.append(loc)
	show_new_items()
#Spawns in new shop items
func show_new_items():
	#Displays a new item for each shop item location
	for location in item_locations.size():
		#Chooses a random item and loads the item from the path, gets it unit_ID
		var chosen_item = choose_random_item()
		#Spawns in the chosen item as a new item in the shop
		var new_item = chosen_item[0].instantiate()
		new_item.unit_ID = chosen_item[1]
		#Sets the new items' parent to be the item location in the shop
		item_locations[location].add_child(new_item)
		#Sets the new items' location to be that of its parent (the shop item location)
		new_item.position = Vector2(0,0)
		
#Chooses a random item
func choose_random_item():
	var dictionary_instance = dictionary.new()
	#Gets a random unit type
	var random_item = (randi_range(1,(dictionary_instance.item_scenes.size()/3))*3)
	#Gets a random number
	var random_percentage = randf_range(1,100)
	var random_level
	if(random_percentage <= level2_percentage):
		random_level = 2
		if(random_percentage <= level3_percentage):
			random_level = 3
	else:
		random_level = 1
	var loaded_item
	if(random_level == 1):
		random_item = random_item-3
		loaded_item = dictionary_instance.item_scenes[random_item]
	elif(random_level == 2):
		#Gets the unit ID
		random_item = random_item-2
		loaded_item = dictionary_instance.item_scenes[random_item]
	elif(random_level == 3):
		#Gets the unit ID
		random_item = random_item-1
		loaded_item = dictionary_instance.item_scenes[random_item]
	#print(random_item)
	return [loaded_item, random_item]
	

func reroll_shop():
	#Remove old shop items before showing new items
	#The items are parented to the shop location they are at, so we loop over every
	#shop location and delete their child
	for location in item_locations:
		#If it doesn't have a child no need to delete the child, this if statement
		#stops crashes
		if(location.get_child_count() > 0):
			location.get_child(0).queue_free()
	print("RE-ROLLED")
	#Gets new items for the shop
	show_new_items()
	
##USED TO REROLL THE SHOP, WILL EVENTUALLY BE DONE BY A BUTTON
func _input(event):
	if Input.is_key_pressed(KEY_R):
		reroll_shop()
