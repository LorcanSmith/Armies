extends Node

#Where should we save the files?
var game_folder = ProjectSettings.globalize_path("res://")

#Saves a grid
func save_layout(grid_name : String, grid_data : Array):
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
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		# Creates the helper class to interact with JSON.
		var json = JSON.new()
		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
	#Returns the contents of the file to whatever called it
	return file_to_load

##USED TO REROLL THE SHOP, WILL EVENTUALLY BE DONE BY A BUTTON
func _input(event):
	if Input.is_key_pressed(KEY_S):
		for grids in self.get_children():
			grids.save_current_grid()
	if Input.is_key_pressed(KEY_L):
		load_layout("army")
