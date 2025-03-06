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
		generator.generate_grid(game_manager.turn_number, game_manager.in_combat)
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
				if(width < unit_IDs.size() and height < unit_IDs[0].size()):	
					var instance				
					if game_manager.in_combat:
						#	reverses tiles for enemy spawning
						var reversed_tiles = tiles.duplicate()
						reversed_tiles.reverse()
						#Loads enemy army
						var enemy_unit_IDs = load_layout("enemy")
						if(enemy_unit_IDs):
							if(unit_IDs[width][height] != null):
								#Spawn in a unit. Reference the UnitDictionary to find out what unit to spawn
								instance = dictionary_instance.unit_scenes[unit_IDs[width][height][0]].instantiate()
								#Add unit ID
								instance.unit_ID = unit_IDs[width][height][0]
								#Add the unit to either the player or the enemy group
								instance.add_to_group("player")
								tiles[width][height].add_child(instance)
								instance.position = Vector2i(0,0)
								tiles[width][height].unit_placed_on(instance)
								instance.skill_damage += unit_IDs[width][height][1]
								instance.max_health += unit_IDs[width][height][2]
								instance.health = instance.max_health
							#If a crash happens here, its likely the enemy army doesn't have an army made for the current turn number
							if(enemy_unit_IDs[width][height] != null):	
								var ID_to_int = int(enemy_unit_IDs[width][height][0])
								#Spawn in a unit. Reference the UnitDictionary to find out what unit to spawn
								instance = dictionary_instance.unit_scenes[ID_to_int].instantiate()
								#Add unit ID
								instance.unit_ID = ID_to_int
								#Add the unit to either the player or the enemy group
								instance.add_to_group("enemy")
								instance.scale.x = -instance.scale.x
								instance.find_child("Label").scale.x = -instance.find_child("Label").scale.x
								reversed_tiles[width][height].add_child(instance)
								instance.position = Vector2i(0,0)
								reversed_tiles[width][height].unit_placed_on(instance)
								
								#NOTE below has to be uncommented when the army generation script has been updated
								#instance.skill_damage += unit_IDs[width][height][1]
								#instance.max_health += unit_IDs[width][height][2]
								#instance.health = instance.max_health
					else:
						if(unit_IDs[width][height] != null):
							#Spawn an item. Reference the UnitDictionary to find out what item to spawn
							instance = dictionary_instance.item_scenes[unit_IDs[width][height][0]].instantiate()
							#Add unit ID
							instance.unit_ID = unit_IDs[width][height][0]
							tiles[width][height].add_child(instance)
							instance.position = Vector2i(0,0)
							tiles[width][height].unit_placed_on(instance)
							#Tell the item it has already been bought
							instance.bought = true
							instance.cost_label = false
							instance.damage_boost += unit_IDs[width][height][1]
							instance.health_boost += unit_IDs[width][height][2]

				height += 1
			width += 1

#Saves a grid
func save_layout(grid_name : String, grid_data : Array):
	if grid_name == "army":
		game_manager.army = grid_data
	#Saves army as an enemy army
	if(DebuggerScript.place_enemy and grid_name != "inventory"):
		grid_name = "enemy"
	
	var current_turn_number = str("turn", game_manager.turn_number)
	
	var json_string
	
	var file_path = game_folder + grid_name + current_turn_number + ".save"
	var save_file
	if FileAccess.file_exists(file_path):
		#This will give you the project directory.
		save_file = FileAccess.open(file_path, FileAccess.READ_WRITE)
		# Move the file cursor to the end of the file (just in case it's not already there)
		save_file.seek_end()
	else:
		save_file = FileAccess.open(file_path, FileAccess.WRITE)
	# JSON provides a static method to serialize the grid_data to a string
	json_string = JSON.stringify(grid_data)
	#print(json_string)
	# Store the save data as a new line in the save file
	save_file.store_line(json_string)
	save_file.close()  # Don't forget to close the file after you're done.
		
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
	var lines = []
	var json = JSON.new()
	#THIS DOESNT SEEM TO PRINT, CRASHES ELSEWHERE
	if not FileAccess.file_exists(game_folder + file_to_load + current_turn_number + ".save"):
		print("ERROR - No data to load", file_to_load)
	else:
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			lines.append(json_string)
	var random_army = randi_range(0, lines.size()-1)
	# Parse the selected line
	var parse_result = json.parse(lines[random_army])
	#Returns the contents of the file to whatever called it
	return json.data

#Returns the grid of the child back to whoever calls the function
func get_grid():
	return get_child(0).grid
