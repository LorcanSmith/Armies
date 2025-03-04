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
	var tiles
	tiles = find_child("grid_generator (army)").grid
	var unit_IDs = game_manager.army
	#This needs to be removed, i dont think it does anything
	if(unit_IDs.size() > 0):
		var width = 0
		while width in range(tiles.size()):
			var height = 0
			while height in range(tiles[width].size()):
				if(width < unit_IDs[0].size()):	
					var instance				
					if game_manager.in_combat:
						#	reverses tiles for enemy spawning
						var reversed_tiles = tiles.duplicate()
						reversed_tiles.reverse()
						#Loads enemy army
						var enemy_unit_IDs = load_layout("enemy")
						
						if(unit_IDs[width][height] != null):
							#Spawn in a unit. Reference the UnitDictionary to find out what unit to spawn
							instance = dictionary_instance.unit_scenes[unit_IDs[width][height][0]].instantiate()
							#Add the unit to either the player or the enemy group
							instance.add_to_group(unit_IDs[width][height][1], true)
							#If the unit is an enemy. Make them face the opposite direction
							tiles[width][height].add_child(instance)
							instance.position = Vector2i(0,0)
							tiles[width][height].unit_placed_on(instance)
						#If a crash happens here, its likely the enemy army doesn't have an army made for the current turn number
						if(enemy_unit_IDs[width][height] != null):	
							var ID_to_int = int(enemy_unit_IDs[width][height][0])
							#Spawn in a unit. Reference the UnitDictionary to find out what unit to spawn
							instance = dictionary_instance.unit_scenes[ID_to_int].instantiate()
							#Add the unit to either the player or the enemy group
							instance.add_to_group(enemy_unit_IDs[width][height][1], true)
							instance.scale.x = -instance.scale.x
							instance.find_child("Label").scale.x = -instance.find_child("Label").scale.x
							reversed_tiles[width][height].add_child(instance)
							instance.position = Vector2i(0,0)
							reversed_tiles[width][height].unit_placed_on(instance)
					else:
						if(unit_IDs[width][height] != null):
							#Spawn an item. Reference the UnitDictionary to find out what item to spawn
							instance = dictionary_instance.item_scenes[unit_IDs[width][height][0]].instantiate()
							tiles[width][height].add_child(instance)
							instance.position = Vector2i(0,0)
							tiles[width][height].unit_placed_on(instance)
							#Tell the item it has already been bought
							instance.bought = true
				height += 1
			width += 1

#Saves a grid
func save_layout(grid_name : String, grid_data : Array):
	if grid_name == "army":
		game_manager.army = grid_data
	#Saves army as an enemy army
	if(DebuggerScript.place_enemy):
		grid_name = "enemy"
	
	var current_turn_number = str("turn", game_manager.turn_number)
	
	#This will give you the project directory.
	var save_file = FileAccess.open(game_folder + grid_name + current_turn_number + ".save", FileAccess.WRITE)
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(grid_data)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)

func load_layout(file_to_load : String):
	var current_turn_number
	#If we're in combat then load this turn nubmer army
	if(game_manager.in_combat):
		current_turn_number = str("turn", game_manager.turn_number)
	#If wer'e in the shop, load the last turn's army as this turn's army hasnt been saved yet
	else:
		current_turn_number = str("turn", (game_manager.turn_number-1))
		
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(game_folder + file_to_load + current_turn_number + ".save", FileAccess.READ)
	var json = JSON.new()
	#THIS DOESNT SEEM TO PRINT, CRASHES ELSEWHERE
	if not FileAccess.file_exists(game_folder + file_to_load + current_turn_number + ".save"):
		print("ERROR - No data to load")
	else:
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
