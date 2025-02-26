extends Node

#Places where shop items show up
var item_locations = []

#Folder containing common shop items
var common_folder = "res://Prefabs/Shop Items/Common/"
#Individual item file names
var common_items: Array = []

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
		var loaded_item = load(str(common_folder + chosen_item))
		#Spawns in the chosen item as a new item in the shop
		var new_item = loaded_item.instantiate()
		#Sets the new items' parent to be the item location in the shop
		item_locations[location].add_child(new_item)
		#Sets the new items' location to be that of its parent (the shop item location)
		new_item.position = Vector2(0,0)
		
#Chooses a random item
func choose_random_item():
	#Gets a random number within the range of how many items there are
	var random_number = randi_range(0, common_items.size()-1)
	#Sends a randomly selected item back to the show_new_items function
	return common_items[random_number]
	
	
#Finds all items in folders
func load_items():
	#Returns an instance for access folder
	var common_folder_instance = DirAccess.open(common_folder)
	#Gets each file out of common folder
	var common_item_files = common_folder_instance.get_files()
	
	#Adds each items' file location to the common items array
	for file_name in common_item_files:
		common_items.append(file_name)
	show_new_items()
