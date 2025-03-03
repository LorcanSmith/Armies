extends Node

#Places where shop items show up
var item_locations = []

#Folder containing shop items
var level1_folder = "res://Prefabs/Shop Items/Level1/"
var level2_folder = "res://Prefabs/Shop Items/Level2/"
#Individual item file names
var level1_items: Array = []
var level2_items : Array = []
#Loads new items and then shows new items in the shop
func _ready() -> void:
	#Gets the children and sets them as locations items can spawn at
	for loc in self.get_children():
		item_locations.append(loc)
	load_items()

#Spawns in new shop items
func show_new_items():
	#Displays a new item for each shop item location
	for location in item_locations.size():
		#Chooses a random item and loads the item from the path
		var chosen_item = choose_random_item()
		#Spawns in the chosen item as a new item in the shop
		var new_item = chosen_item.instantiate()
		#Sets the new items' parent to be the item location in the shop
		item_locations[location].add_child(new_item)
		#Sets the new items' location to be that of its parent (the shop item location)
		new_item.position = Vector2(0,0)
		
#Chooses a random item
func choose_random_item():
	var random_folder = randi_range(1,2)
	#Gets a random number within the range of how many items there are
	var random_item = randi_range(0, level1_items.size()-1)
	var loaded_item
	if(random_folder == 1):
		loaded_item = load(str(level1_folder + level1_items[random_item]))
	elif(random_folder == 2):
		loaded_item = load(str(level2_folder + level2_items[random_item]))
	return loaded_item
	
	
#Finds all items in folders
func load_items():
	#Returns an instance for access folder
	var level1_folder_instance = DirAccess.open(level1_folder)
	var level2_folder_instance = DirAccess.open(level2_folder)
	#Gets each file out of common folder
	var level1_item_files = level1_folder_instance.get_files()
	var level2_item_files = level2_folder_instance.get_files()
	
	#Adds each items' file location to the common items array
	for file_name in level1_item_files:
		level1_items.append(file_name)
	for file_name in level2_item_files:
		level2_items.append(file_name)
	show_new_items()

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
