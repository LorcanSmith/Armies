extends Node2D

var seed : int = "Godot Rocks".hash()

# swaps between the battle and shop scene

#List of all managers
var CombatManager : Node2D
var ShopManager : Node2D
var GridManager : Node2D

#Canvas for making team name
var name_canvas : CanvasLayer
#Team name words
var adjective : String
var noun : String

#The current scene we are on
var current_scene : Node2D

#Base
@export var bases_appear_on_turn_numbers : Array = [1, 4, 6]
var base_crate_spawner : Node2D
var base_ID : int = -1
var base_name : String
var base_sprite : Texture2D
#Base stats
var tier : int = 0
#Special
var base_description : String
var extra_money : int = 0
#Themes
var medieval_health : int = 0
var medieval_attack : int = 0
var army_health : int = 0
var army_attack : int = 0
var dinosaur_health : int = 0
#Types
var vehicle_health : int = 0
var vehicle_attack : int = 0
var human_health : int = 0
var human_attack : int = 0
var animal_health : int = 0
var animal_attack : int = 0
var healer_health : int = 0
var healer_attack : int = 0
#Names
var soldier_health : int = 0
var soldier_attack : int = 0
var velociraptor_health : int = 0
var velociraptor_attack : int = 0


#Just the unit IDS
var army : Array
#The actual units themselves
var army_units : Array
#Just the enemy unit IDS
var enemy_army : Array

var shop_scene = preload("res://Prefabs/Managers/shop_manager.tscn")
var combat_scene = preload("res://Prefabs/Managers/combat_manager.tscn")

var coin_counter_scene = preload("res://Prefabs/Effects/UI/coin_counter.tscn")

var in_combat : bool = false

var debug_mode : bool = false

#What turn are we on
var turn_number = 0
#How many wins do we have
var wins = 0
#How much life are we on
var life_remaining = 10

#number of shop upgrades purchased
var shop_upgrades : int = 0
#shop buff that keeps track of number of slots available in the shop
var shop_slots : int = 4
#list of unit types that have been removed from the shop pool
var blocked_types = []
#maximum number of shop slots the game supports
const MAX_SHOP_SLOTS = 9


@export var auto_create_armies_at_runtime : bool

var money_remaining : int = 0
@export var health_UI : Control
@export var wins_UI : Control
@export var coin_text : RichTextLabel
@export var turn_text : RichTextLabel
@export var health_counter : RichTextLabel
@export var coin_counter : RichTextLabel
@export var turn_counter : RichTextLabel
@export var win_counter : RichTextLabel

var game_over_canvas : CanvasLayer

func _ready():
	seed = randi_range(0,9999999999)
	update_seed_label_text()
	update_tick_label_text(0)
	in_combat = false
	coin_text.text = str(0)
	game_over_canvas = find_child("game_over_canvas")
	if(auto_create_armies_at_runtime):
		DebuggerScript.create_enemy_armies()
	create_scene()


func swap_scenes():
	if(!game_over_canvas.visible):
		army_units = []
		if(!in_combat):
			for grids in GridManager.get_children():
				grids.save_current_grid()
		#reverses the value of in_combat boolean
		in_combat = !in_combat
		
		if(turn_number == 1 and name_canvas):
			#Turn on name maker UI
			name_canvas.visible = true
			#Set size to 0 so it can animate in
			name_canvas.find_child("ColorRect").scale = Vector2(0,0)
			#Play animation to make the canvas pop in
			name_canvas.get_node("AnimationPlayer").play("name_maker_appear")
			#Select random names for selections
			select_words()
		else:
			find_child("scene_transitions").get_node("scene_transition_animation_player").play("transition_in")
	
func create_scene():
	
	if in_combat:
		current_scene = combat_scene.instantiate()
	else:
		turn_number += 1
		$UI/Turns.play("fade_in")
		turn_text.text = str(turn_number)
		current_scene = shop_scene.instantiate()
		#Tell the base manager to set its base and to do start of turn effects
	add_child(current_scene)
	
	#Sets all the managers to be that of the newly instantiated scene
	CombatManager = get_node_or_null("combat_manager")
	ShopManager = get_node_or_null("shop_manager")
	if(ShopManager != null):
		ShopManager.game_manager = self
		if(!in_combat):
			#Tells the base manager what the current base is
			ShopManager.find_child("base_manager").set_base(base_ID, base_name, base_description, false)
			#Calls start of turn actions for the current base
			ShopManager.find_child("base_manager").start_of_turn()
		elif(in_combat):
			CombatManager.player_base_sprite = base_sprite
			CombatManager.find_child("player_team_name").text = ("The " + adjective + " " + noun)
	GridManager = current_scene.find_child("grid_manager")	
	load_complete("scene")

func load_complete(element_loaded : String):
	if(!game_over_canvas.visible):
		if(element_loaded == "scene"):
			GridManager.generate_grids()
		if(element_loaded == "grids"):
			if(in_combat):
				CombatManager.setup_headquarters(base_sprite)

func _input(event):
	if Input.is_action_just_pressed("save"):
		for grids in GridManager.get_children():
			grids.save_current_grid()
#	pauses/restarts the battle ticks, can be used in conjunction with "T" to step through a battle
	if Input.is_action_just_pressed("pause"):
		if (CombatManager!= null):
			CombatManager.ticker_paused = !CombatManager.ticker_paused
			if !CombatManager.ticker_paused:
				CombatManager.battle_ticker()
	if Input.is_action_just_pressed("tick"):
		if (CombatManager!= null):
			CombatManager.battle_ticker()
	if Input.is_key_pressed(KEY_N):
		DebuggerScript.create_enemy_armies()
	if Input.is_key_pressed(KEY_D):
		DebuggerScript.save_report(self)
	if Input.is_key_pressed(KEY_R):
		DebuggerScript.run_report(self)
func money_changed(amount : int):
	var coin_counter = coin_counter_scene.instantiate()
	$UI/HBoxContainer/dollar_control/CoinNotifs.add_child(coin_counter)
	if money_remaining > amount:
		coin_counter.text = str(amount - money_remaining)
	else:
		coin_counter.text = "+" + str(amount - money_remaining)
	coin_counter.find_child("AnimationPlayer").play("fade_in")
	var tween = coin_text.create_tween()
	tween.tween_method(set_label_text, money_remaining, amount, 0.6)
	money_remaining = amount

func set_label_text(value: int):
	coin_text.text = str(value)

#Called by combat manager when our headquarters is destroyed
func won_battle(won : bool, draw : bool):
	#If we won
	if(won):
		#Add a win
		wins += 1
		$UI/Wins.play("fade_in")
		#If we haven't won the whole game (10 wins)
		if(wins == 10):
			show_game_over(true)
	#A round was lost
	elif(!won and !draw):
		#Does a different amount of damage based on the turn number
		if(turn_number == 1):
			life_remaining -= 1
		elif(turn_number == 2):
			life_remaining -= 2
		else:
			life_remaining -= 3
	#Round draw
	elif(!won and draw):
		pass
	#Update wins/life UI visuals
	var n = 0
	while n < wins:
		if(wins_UI.get_child(n).visible == false):
			wins_UI.get_child(n).find_child("trophy_gain_anim_player").play("trophy_gain")
		wins_UI.get_child(n).visible = true
		n += 1
	n = 10
	while n > life_remaining:
		if(health_UI.get_child(n-1).visible == true):
			health_UI.get_child(n-1).find_child("life_lose_anim_player").play("lose_life")
			await get_tree().create_timer(.5).timeout
		n-=1
			
			
	$UI/Health.play("fade_in")	
	#If we no longer have life left, its game over
	if(life_remaining <= 0):	
		show_game_over(false)
 	
func show_game_over(win : bool):
	find_child("scene_transitions").get_node("scene_transition_animation_player").play("transition_in")
	game_over_canvas.visible = true
	if(win):
		game_over_canvas.find_child("Title").text = "10 Wins! You win!"
	else:
		game_over_canvas.find_child("Title").text = "You Lose!"


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func select_words():
	var game_folder = ProjectSettings.globalize_path("res://")
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var adjectives_file = FileAccess.open(game_folder + "Adjectives.txt", FileAccess.READ)
	var nouns_file = FileAccess.open(game_folder + "Nouns.txt", FileAccess.READ)
	var adjectives = []
	var nouns = []
	var json = JSON.new()
	if not FileAccess.file_exists(game_folder + "Adjectives.txt"):
		print("ERROR - No data to load", "-ADJECTIVES")
	else:
		while adjectives_file.get_position() < adjectives_file.get_length():
			var json_string = adjectives_file.get_line()
			adjectives.append(json_string)
	if not FileAccess.file_exists(game_folder + "Nouns.txt"):
		print("ERROR - No data to load", "-NOUNS")
	else:
		while nouns_file.get_position() < nouns_file.get_length():
			var json_string = nouns_file.get_line()
			var parsed = json.parse(json_string)
			nouns.append(json_string)
			
	#Choose random words
	var random_adjective1 = adjectives[randi_range(0, adjectives.size()-1)]
	adjectives.erase(random_adjective1)
	var random_adjective2 = adjectives[randi_range(0, adjectives.size()-1)]
	adjectives.erase(random_adjective2)
	var random_adjective3 = adjectives[randi_range(0, adjectives.size()-1)]
	var chosen_adjectives = [random_adjective1, random_adjective2, random_adjective3]
	
	var random_noun1 = nouns[randi_range(0, nouns.size()-1)]
	nouns.erase(random_noun1)
	var random_noun2 = nouns[randi_range(0, nouns.size()-1)]
	nouns.erase(random_adjective2)
	var random_noun3 = nouns[randi_range(0, nouns.size()-1)]
	var chosen_nouns = [random_noun1, random_noun2, random_noun3]
	#Assign words to buttons
	var adjectives_buttons = name_canvas.find_child("top_words").get_children()
	var nouns_buttons = name_canvas.find_child("bottom_words").get_children()
	
	var x = 0
	while x < adjectives_buttons.size():
		if(chosen_adjectives[x]):
			adjectives_buttons[x].get_child(0).text = chosen_adjectives[x]
			adjectives_buttons[x].word = chosen_adjectives[x]
		else:
			adjectives_buttons[x].get_child(0).text = "test2"
			adjectives_buttons[x].word = "test2"
		x += 1
	x = 0
	while x < nouns_buttons.size():		
		if(chosen_nouns[x]):
			nouns_buttons[x].get_child(0).text = chosen_nouns[x]
			nouns_buttons[x].word = chosen_nouns[x]
		else:
			nouns_buttons[x].get_child(0).text = "test"
			nouns_buttons[x].word = "test"
		x+=1
		
func word_pressed(is_adjective, word):
	if(is_adjective):
		adjective = word
	else:
		noun = word
	#both and adjective and noun has been chosen
	if(adjective and noun):
		#Turn on confirm button
		name_canvas.find_child("confirm_name_button").visible = true
		#Set team name text
		var team_name = "The " + adjective + " " + noun
		name_canvas.find_child("chosen_name").text = (team_name)

func _on_confirm_name_button_pressed() -> void:

#	Create User with Name
	var team_name = name_canvas.find_child("chosen_name").text
	
#	This will get used later on for the request for enemy team
	ServerRequestManager.start_with_new_team(team_name)
	
	name_canvas.queue_free()
	find_child("scene_transitions").get_node("scene_transition_animation_player").play("transition_in")
	
func set_enemy_name(enemy_name: String):
	CombatManager.find_child("enemy_team_name").text = enemy_name
	
func update_seed_label_text():
	find_child("seed").text = str("seed: ", seed)
	
func update_tick_label_text(tick: int):
	find_child("tick").text = str("tick: ", tick)


func _on_scene_transition_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "transition_in" and !game_over_canvas.visible):
		find_child("scene_transitions").get_node("scene_transition_animation_player").play("transition_out")
		current_scene.queue_free()
		create_scene()
