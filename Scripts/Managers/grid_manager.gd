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
	var enemy_unit_IDs
	if game_manager.in_combat:
		if game_manager.debug_mode:
			enemy_unit_IDs = game_manager.enemy_army
		else:
			#var error_code = await ServerRequestManager.upload(unit_IDs, game_manager.turn_number)
			#var enemy_team_info_response = await ServerRequestManager.upload_complete
			#if(error_code == OK and !enemy_team_info_response["error"]):				
				#enemy_unit_IDs = enemy_team_info_response["enemy_game_state"]
				#game_manager.enemy_army = enemy_unit_IDs
				#game_manager.set_enemy_name(enemy_team_info_response["enemy_user"])
			#else:
##				TODO For now we will just not deal with the error, but in the future we should handle this better
##				such as with a retry
				#var error_string = enemy_team_info_response["message"] + " SERVER ERROR CODE = " + enemy_team_info_response["code"] if error_code == OK else "Error with request - " + str(error_code)
				#print(error_string)

#				if we can't get enemy data from the server default to the previous local method 
				enemy_unit_IDs = load_layout("enemy")
				game_manager.enemy_army = enemy_unit_IDs
				
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
						if(enemy_unit_IDs):
							if(unit_IDs[width][height] != null):
								#Spawn in a unit. Reference the UnitDictionary to find out what unit to spawn
								instance = dictionary_instance.unit_scenes[int(unit_IDs[width][height][0])].instantiate()
								#Add unit ID
								instance.unit_ID = unit_IDs[width][height][0]
								#Add the unit to either the player or the enemy group
								instance.add_to_group("player")
								tiles[width][height].add_child(instance)
								instance.position = Vector2i(0,0)
								tiles[width][height].unit_placed_on(instance)
								instance.set_damage_and_health(unit_IDs[width][height][1],unit_IDs[width][height][2])
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
								instance.find_child("health_bar_background").scale.x = -instance.find_child("health_bar_background").scale.x
								instance.find_child("ammo_bar_background").scale.x = -instance.find_child("ammo_bar_background").scale.x
								instance.find_child("Sprite2D").self_modulate = instance.find_child("Sprite2D").self_modulate + Color(0.2,-0.3,-0.3)
								reversed_tiles[width][height].add_child(instance)
								instance.position = Vector2i(0,0)
								reversed_tiles[width][height].unit_placed_on(instance)
								
								instance.skill_damage += enemy_unit_IDs[width][height][1]
								instance.max_health += enemy_unit_IDs[width][height][2]
								instance.health = instance.max_health
					else:
						if(unit_IDs[width][height] != null):
							#Spawn an item. Reference the UnitDictionary to find out what item to spawn
							instance = dictionary_instance.item_scenes[int(unit_IDs[width][height][0])].instantiate()
			
							#Add unit ID
							instance.unit_ID = unit_IDs[width][height][0]
							tiles[width][height].add_child(instance)
							instance.position = Vector2i(0,0)
							tiles[width][height].unit_placed_on(instance)
							instance.cost_label.visible = false
							instance.damage_boost += unit_IDs[width][height][1]
							instance.health_boost += unit_IDs[width][height][2]
							instance.update_label_text()
							#Increase shop percentages if the unit can do it
							get_parent().find_child("shop_item_generator").level2_percentage += instance.increase_higher_level_unit_perecentage/100
							get_parent().find_child("shop_item_generator").level3_percentage += instance.increase_higher_level_unit_perecentage/100
							#Gets the unit version so we can check if the item needs to be transformed
							var unit_version = dictionary_instance.unit_scenes[int(unit_IDs[width][height][0])].instantiate()
							instance.transform_item(unit_version)
				height += 1
			width += 1
	#units have been loaded in
	if(!game_manager.in_combat):
		get_parent().find_child("shop_item_generator").show_new_units()
func load_layout(file_to_load : String):
	var current_turn_number
	#If we're in combat then load this turn number army
	if(game_manager.in_combat):
		current_turn_number = str("turn", game_manager.turn_number)
	#If we're in the shop, load the last turn's army as this turn's army hasnt been saved yet
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
