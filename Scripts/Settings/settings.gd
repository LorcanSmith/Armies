extends Node

var volume : float = -80
var fullscreen : bool = false

#Tutorials
var tutorials_enabled : bool = true
var unit_tutorial_completed : bool = false
var battle_tutorial_completed : bool = false
var health_tutorial_completed : bool = false

func _ready() -> void:
	load_game()

func change_volume(percent: float):
	if(percent <= 0):
		volume = -80
	else:
		volume = lerp(-80, 50, percent / 100.0)
	save_game()

func changed_fullscreen(fullscreen_on):
	fullscreen = fullscreen_on
	save_game()
	
func completed_tutorial(tutorial_name : String):
	if(tutorial_name == "unit"):
		unit_tutorial_completed = true
	if(tutorial_name == "battle"):
		battle_tutorial_completed = true
	if(tutorial_name == "health"):
		health_tutorial_completed = true
		tutorials_enabled = false
	save_game()

func reset_tutorials():
	tutorials_enabled = true
	unit_tutorial_completed = false
	battle_tutorial_completed = false
	health_tutorial_completed = false
	save_game()
func save_game():
	var data = {
		"volume": volume,
		"fullscreen": fullscreen,
		"tutorials_enabled": tutorials_enabled,
		"unit_tutorial_completed": unit_tutorial_completed,
		"battle_tutorial_completed": battle_tutorial_completed,
		"health_tutorial_completed": health_tutorial_completed
	}
	print("Saving data: ", data)  # Add this line
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if FileAccess.file_exists("user://save_data.json"):
		var file = FileAccess.open("user://save_data.json", FileAccess.READ)
		var content = file.get_as_text()
		file.close()

		var data = JSON.parse_string(content)
		if typeof(data) == TYPE_DICTIONARY:
			print("Loaded data: ", data)
			volume = data.get("volume", volume)
			fullscreen = data.get("fullscreen", fullscreen)
			tutorials_enabled = data.get("tutorials_enabled", tutorials_enabled)
			unit_tutorial_completed = data.get("unit_tutorial_completed", unit_tutorial_completed)
			battle_tutorial_completed = data.get("battle_tutorial_completed", battle_tutorial_completed)
			health_tutorial_completed = data.get("health_tutorial_completed", health_tutorial_completed)
		else:
			print("Failed to parse JSON")
