extends Node2D

# swaps between the battle and shop scene

#List of all managers
var CombatManager : Node2D
var ShopManager : Node2D
var GridManager : Node2D

#The current scene we are on
var current_scene : Node2D

#Base
@export var bases_appear_on_turn_numbers : Array = [1, 4, 6]
var base_crate_spawner : Node2D
var base_ID : int
var base_name : String
var base_description : String
var base_sprite : Texture2D

#Just the unit IDS
var army : Array
#The actual units themselves
var army_units : Array

var shop_scene = preload("res://Prefabs/Managers/shop_manager.tscn")
var combat_scene = preload("res://Prefabs/Managers/combat_manager.tscn")

var in_combat : bool = false

#What turn are we on
var turn_number = 0
#How many wins do we have
var wins = 0
#How much life are we on
var life_remaining = 10

@export var auto_create_armies_at_runtime : bool

var money_remaining : int = 0
@export var health_text : RichTextLabel
@export var coin_text : RichTextLabel
@export var turn_text : RichTextLabel
@export var wins_text : RichTextLabel
@export var health_counter : RichTextLabel
@export var coin_counter : RichTextLabel
@export var turn_counter : RichTextLabel
@export var win_counter : RichTextLabel

var game_over_canvas : CanvasLayer

func _ready():
	in_combat = false
	health_text.text = str(life_remaining)
	coin_text.text = str(0)
	game_over_canvas = find_child("game_over_canvas")
	if(auto_create_armies_at_runtime):
		DebuggerScript.create_enemy_armies()
	create_scene()


func swap_scenes():
	army_units = []
	if(!in_combat):
		for grids in GridManager.get_children():
				grids.save_current_grid()
	#reverses the value of in_combat boolean
	in_combat = !in_combat
	current_scene.queue_free()
	create_scene()
	
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
			ShopManager.find_child("base_manager").set_base(base_ID, base_name, base_description)
			#Calls start of turn actions for the current base
			ShopManager.find_child("base_manager").start_of_turn()
			base_crate_spawner = ShopManager.find_child("base_spawn_location")
			#Spawn in base crate if it is the right turn number
			if(bases_appear_on_turn_numbers.has(turn_number)):
				base_crate_spawner.spawn_base_crate()
		elif(in_combat):
			CombatManager.player_base_sprite = base_sprite
	GridManager = current_scene.find_child("grid_manager")	
	load_complete("scene")

func load_complete(element_loaded : String):
	if(element_loaded == "scene"):
		GridManager.generate_grids()
	if(element_loaded == "grids"):
		if(in_combat):
			CombatManager.setup_headquarters(base_sprite)
	
##USED TO REROLL THE SHOP, WILL EVENTUALLY BE DONE BY A BUTTON
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
	
func money_changed(amount : int):
	$UI/Coins.stop()
	if money_remaining > amount:
		coin_counter.text = str(amount - money_remaining)
	else:
		coin_counter.text = "+" + str(amount - money_remaining)
	$UI/Coins.play("fade_in")
	var tween = coin_text.create_tween()
	tween.tween_method(set_label_text, money_remaining, amount, 1).set_delay(1)
	money_remaining = amount

func set_label_text(value: int):
	coin_text.text = str(value)

#Called by combat manager when our headquarters is destroyed
func won_battle(won : bool):
	#If we won
	if(won):
		#Add a win
		wins += 1
		$UI/Wins.play("fade_in")
		#If we haven't won the whole game (10 wins)
		if(wins == 10):
			show_game_over(true)
	#A round was lost
	else:
		#Does a different amount of damage based on the turn number
		if(turn_number == 1):
			life_remaining -= 1
			health_counter.text = "-1"
		elif(turn_number == 2):
			life_remaining -= 2
			health_counter.text = "-2"
		else:
			life_remaining -= 3
			health_counter.text = "-3"
			
		$UI/Health.play("fade_in")	
		#If we no longer have life left, its game over
		if(life_remaining <= 0):	
			show_game_over(false)
#	Updates UI text
	health_text.text = str(life_remaining)
	wins_text.text = str(wins)
	
func show_game_over(win : bool):
	game_over_canvas.visible = true
	if(win):
		game_over_canvas.find_child("Title").text = "10 Wins! You win!"
	else:
		game_over_canvas.find_child("Title").text = "You Lose!"


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
