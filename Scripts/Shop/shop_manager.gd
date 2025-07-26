extends Node

#The Game Manager
var game_manager
var status_bar: StatusBar

@export var free_reroll : bool = true
@export var reroll_cost : int = 2

#Amount of money the player can spend each turn
@export var money : int = 30
var same_units = []
var tiles_to_delete_units_from = []

var sound_stream : AudioStream = preload("res://Sounds/test.mp3")
var player
var text_starting_scale : Vector2

#Tutorial to remove when its time
var unit_tutorial : Node2D
var battle_tutorial : Node2D

func _ready() -> void:
	#For playing audio like music
	text_starting_scale = find_child("volume_text").scale
	player = AudioStreamPlayer.new()
	add_child(player)
	#Setting previously saved settings
	find_child("Volume_Slider").value = 100 * ((Settings.volume+80)/130)
	_on_fullscreen_button_toggled(Settings.fullscreen)
	find_child("Fullscreen_Button").button_pressed = Settings.fullscreen

	
	game_manager = find_parent("game_manager")
	money += game_manager.money_remaining
	game_manager.money_changed(money)
	
#Called when we want to add or take away money
func change_money(amount : int):
	money -= amount
	game_manager.money_changed(money)
	
	#For the first time we spend money we should delete the unit_tutorial if it exists
	if(unit_tutorial):
		unit_tutorial.get_node("AnimationPlayer").play("pop_out")
	if(find_child("onboarding")):
		find_child("onboarding").check_tutorials()
func _on_battle_button_pressed() -> void:
	find_child("battle_button").visible = false
	apply_buffs()
			
func apply_buffs():	
	find_child("grid_generator (army)").save_current_grid()
	var tiles = find_child("grid_manager").find_child("grid_generator (army)").get_children()
	var x = 0
	#Loops over all tiles
	while (x < (tiles.size())):
		var y = 0
		var children = tiles[x].get_children()
		while (y < (children.size())):
			#If there is a item on the tile
			if(children[y].is_in_group("item")):
				#Add it to the same units array
				if(children[y].can_buff):
					children[y].buff()
			y+=1
		x+=1
	find_child("buff_animation_holder").waiting_for_skills = true

func no_skills_left():
	if tiles_to_delete_units_from.size() > 0:
		var x = 0
		while x < tiles_to_delete_units_from.size():
			if(tiles_to_delete_units_from[x].is_in_group("tile")):
				tiles_to_delete_units_from[x].is_empty = true
				tiles_to_delete_units_from[x].units_on_tile.erase(tiles_to_delete_units_from[x])
			x += 1
	find_child("grid_generator (army)").save_current_grid()
	game_manager.swap_scenes()

func kill_units():
	var tiles = find_child("grid_manager").find_child("grid_generator (army)").get_children()
	var x = 0
	#Loops over all tiles
	while (x < (tiles.size())):
		var y = 0
		var children = tiles[x].get_children()
		while (y < (children.size())):
			#If there is a item on the tile
			if(children[y].is_in_group("item")):
				#Add it to the same units array
				children[y].health_check()
			y+=1
		x+=1

func _on_battle_button_button_down():
	if find_child("BattleText"):
		find_child("BattleText").modulate = Color(0, .6, 0, 1)

func _on_battle_button_mouse_entered():
	if find_child("BattleText"):
		find_child("BattleText").modulate = Color(0, .8, 0, 1)

func _on_battle_button_mouse_exited():
	if find_child("BattleText"):
		find_child("BattleText").modulate = Color(1, 1, 1, 1)


func _on_reroll_button_button_down():
	if find_child("RerollText"):
		find_child("RerollText").modulate = Color(0.6, 0.6, 0.6, 0.6)


func _on_reroll_button_mouse_entered():
	if find_child("RerollText"):
		find_child("RerollText").modulate = Color(.8, .8, .8, .8)


func _on_reroll_button_mouse_exited():
	if find_child("RerollText"):
		find_child("RerollText").modulate = Color(1, 1, 1, 1)

#Turn on the unit section of the shop
func _on_shop_unit_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		find_child("unit_section").visible = true
		find_child("shop_remove_section").visible = false
		find_child("settings_section").visible = false
func _on_shop_upgrade_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		find_child("unit_section").visible = false
		find_child("shop_remove_section").visible = true
		find_child("settings_section").visible = false
func _on_texture_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		find_child("unit_section").visible = false
		find_child("shop_remove_section").visible = false
		find_child("settings_section").visible = false

func _on_shop_settings_b_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		find_child("unit_section").visible = false
		find_child("shop_remove_section").visible = false
		find_child("settings_section").visible = true


func _on_volume_slider_value_changed(value: float) -> void:
	Settings.change_volume(value)
	#Set volume percentage
	player.volume_db = Settings.volume
	find_child("volume_text").scale = text_starting_scale * (1 + ((Settings.volume + 80)/130))


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	Settings.changed_fullscreen(toggled_on)
	if(toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif(!toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)



func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_reset_tutorials_button_pressed() -> void:
	Settings.reset_tutorials()
