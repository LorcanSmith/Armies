extends Node
#The Game Manager
var game_manager
#Where should we save the files?
var game_folder = ProjectSettings.globalize_path("res://")
var test_unit = preload("res://Prefabs/Units/Level1/Knight.tscn")



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
	var tiles = get_child(0).grid
	var unit_IDs = game_manager.army
	#If we are in combat unit_IDs will be > 0 therefore we should load in units
	if(unit_IDs.size() > 0):
	#	reverses enemy army position so that they are placed 180 degrees
		#var enemy_army = game_manager.send_enemy_army()
		#for column in range(enemy_army.size()):
			#enemy_army[column].reverse()
		#enemy_army.reverse()
		
		for width in range(tiles.size()):
			for height in range(tiles[width].size()):
				if unit_IDs[width][height] != null:
					
	#				TODO
	#				translate Unit ID to appropriate unit

					var instance = test_unit.instantiate()
					
					tiles[width][height].add_child(instance)
					instance.position = Vector2i(0,0)
					tiles[width][height].unit_placed_on(instance)
					
	#	TODO
	#	spawn enemies on other side of the grid

#Saves a grid
func save_layout(grid_name : String, grid_data : Array):
	game_manager.army = grid_data
	#This will give you the project directory.
	var save_file = FileAccess.open(game_folder + grid_name + ".save", FileAccess.WRITE)
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(grid_data)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)

func load_layout(file_to_load : String):
	if not FileAccess.file_exists(game_folder + "army.save"):
		print("ERROR - No data to load")

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(game_folder + file_to_load + ".save", FileAccess.READ)
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
