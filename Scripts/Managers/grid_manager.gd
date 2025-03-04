extends Node
#The Game Manager
var game_manager
#Where should we save the files?
var game_folder = ProjectSettings.globalize_path("res://")

var dictionary = load("res://Scripts/Units/dictionary.gd")

func _ready() -> void:
	game_manager = find_parent("game_manager")
	

func generate_grids():
	#Tells all the grid generators to make a grid
	for generator in get_children():
		generator.generate_grid()
	game_manager.load_complete("grids")
	#Loads units into the scene
	load_units()


func load_units():
	var dictionary_instance = dictionary.new()
	
	var tiles = find_child("grid_generator (army)").grid
	var tiles_reversed = tiles
	tiles_reversed.reverse()
	var unit_IDs = game_manager.army
	
	#If we are in combat unit_IDs will be > 0 therefore we should load in units
	if(unit_IDs.size() > 0):
		#Gets enemy IDs
		var enemy_unit_IDs = load_layout("enemy")
		#Reverse them to spawn in backwards
		enemy_unit_IDs.reverse()

		var width = 0
		while width in range(tiles.size()):
			var height = 0
			while height in range(tiles[width].size()):
				if(width < unit_IDs[0].size()):	
					var instance
					if game_manager.in_combat:
						if(unit_IDs[width][height] != null):
							#Spawn in a unit. Reference the UnitDictionary to find out what unit to spawn
							instance = dictionary_instance.unit_scenes[unit_IDs[width][height][0]].instantiate()
							#Add the unit to the player group
							instance.add_to_group(unit_IDs[width][height][1], true)
							instance.position = Vector2i(0,0)
							tiles[width][height].add_child(instance)
							tiles[width][height].unit_placed_on(instance)
						elif(enemy_unit_IDs[width][height] != null):
							#Spawn in a unit. Reference the UnitDictionary to find out what unit to spawn
							var to_int = int(enemy_unit_IDs[width][height][0])
							instance = dictionary_instance.unit_scenes[to_int].instantiate()
							#Add the unit to the enemy group
							instance.add_to_group(enemy_unit_IDs[width][height][1], true)
							#The unit is an enemy. Make them face the opposite direction
							instance.scale.x = -instance.scale.x
							instance.find_child("Label").scale.x = -instance.find_child("Label").scale.x
							instance.position = Vector2i(0,0)
							tiles_reversed[width][height].add_child(instance)
							tiles_reversed[width][height].unit_placed_on(instance)
					else:
						if(unit_IDs[width][height] != null):
							#Spawn an item. Reference the UnitDictionary to find out what item to spawn
							instance = dictionary_instance.item_scenes[unit_IDs[width][height][0]].instantiate()
							#Tell the item it has already been bought
							instance.bought = true
							instance.position = Vector2i(0,0)
						
				height += 1
			width += 1
#Saves a grid
func save_layout(grid_name : String, grid_data : Array):
	if grid_name == "army":
		game_manager.army = grid_data
	var turn_number = str(game_manager.current_turn_number)
	##DEBUG
	var army_is_enemy = DebuggerScript.save_enemy_army
	if(army_is_enemy):
		grid_name = "enemy"
	#This will give you the project directory.
	var save_file = FileAccess.open(game_folder + grid_name + turn_number + ".save", FileAccess.WRITE)
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(grid_data)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)


func load_layout(file_to_load : String):
	if not FileAccess.file_exists(game_folder + "army.save"):
		print("ERROR - No data to load")
	var turn_number
	if(game_manager.in_combat):
		turn_number = str(game_manager.current_turn_number)
	else:
		turn_number = str(game_manager.current_turn_number-1)
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(game_folder + file_to_load + turn_number + ".save", FileAccess.READ)
	var json = JSON.new()

	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		# Creates the helper class to interact with JSON.
		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

	#Returns the contents of the file to whatever called it
	return json.data

#Returns the grid of the child back to whoever calls the function
func get_grid():
	return get_child(0).grid
