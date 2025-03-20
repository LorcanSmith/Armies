extends Node2D

# swaps between the battle and shop scene

#List of all managers
var CombatManager : Node2D
var ShopManager : Node2D
var GridManager : Node2D

#The current scene we are on
var current_scene : Node2D

var army : Array

var shop_scene = preload("res://Prefabs/Managers/shop_manager.tscn")
var combat_scene = preload("res://Prefabs/Managers/combat_manager.tscn")

var in_combat : bool = false

#What turn are we on
var turn_number = 0
#How many wins do we have
var wins = 0
#How much life are we on
var life_remaining = 10

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
	game_over_canvas = find_child("game_over_canvas")
	create_scene()


func swap_scenes():
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
	add_child(current_scene)
	
	#Sets all the managers to be that of the newly instantiated scene
	CombatManager = get_node_or_null("combat_manager")
	ShopManager = get_node_or_null("shop_manager")
	if(ShopManager != null):
		ShopManager.game_manager = self
	GridManager = current_scene.find_child("grid_manager")
	
	load_complete("scene")

	await get_tree().create_timer(1.5).timeout
	$UI/Turns.play("fade_out")

func load_complete(element_loaded : String):
	if(element_loaded == "scene"):
		GridManager.generate_grids()
	if(element_loaded == "grids"):
		if(in_combat):
			CombatManager.setup_headquarters()
		
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
	if money_remaining > amount:
		coin_counter.text = str(amount - money_remaining)
	else:
		coin_counter.text = "+" + str(amount - money_remaining)
	$UI/Coins.play("fade_in")
	coin_text.text = str(amount)
	money_remaining = amount
	await get_tree().create_timer(1.5).timeout
	$UI/Coins.play("fade_out")
#Called by combat manager when our headquarters is destroyed
func won_battle(won : bool):
	#If we won
	if(won):
		#Add a win
		wins += 1
		$UI/Wins.play("fade_in")
		wins_text.text = str(wins)
		await get_tree().create_timer(1.5).timeout
		$UI/Wins.play("fade_out")
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
		health_text.text = str(life_remaining)
		await get_tree().create_timer(1.5).timeout
		$UI/Health.play("fade_out")
		#If we no longer have life left, its game over
		if(life_remaining <= 0):	
			show_game_over(false)
	
func show_game_over(win : bool):
	game_over_canvas.visible = true
	if(win):
		game_over_canvas.find_child("Title").text = "10 Wins! You win!"
	else:
		game_over_canvas.find_child("Title").text = "You Lose!"


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
