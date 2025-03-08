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

var status_bar : StatusBar

var in_combat : bool = false

#What turn are we on
var turn_number = 0
#How many wins do we have
var wins = 0
#How much life are we on
var life_remaining = 10

@export var health_text : RichTextLabel
@export var coin_text : RichTextLabel

func _ready():
	in_combat = false
	status_bar = get_node("StatusBarLayer/StatusBar")
	health_text.text = str(life_remaining)
	create_scene()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		for grids in GridManager.get_children():
			grids.save_current_grid()
		swap_scenes()
		
func swap_scenes():
	#reverses the value of in_combat boolean
	in_combat = !in_combat
	current_scene.queue_free()
	create_scene()
	
func create_scene():
	if in_combat:
		current_scene = combat_scene.instantiate()
	else:
		turn_number += 1
		current_scene = shop_scene.instantiate()
		current_scene.money_changed.connect(_money_changed)
	add_child(current_scene)
	
	#Sets all the managers to be that of the newly instantiated scene
	CombatManager = get_node_or_null("combat_manager")
	ShopManager = get_node_or_null("shop_manager")
	if(ShopManager != null):
		ShopManager.game_manager = self
	GridManager = current_scene.find_child("grid_manager")
	
	load_complete("scene")

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
	
func _money_changed(amount : int):
	coin_text.text = str("$   ", amount)

#Called by combat manager when our headquarters is destroyed
func won_battle(won : bool):
	#If we won
	if(won):
		#Add a win
		wins += 1
		#If we haven't won the whole game (10 wins)
		if(wins < 10):
			print("WINS: ", wins)
		else:
			print("10 WINS! GAME OVER, YOU WIN!")
	#A round was lost
	else:
		#Does a different amount of damage based on the turn number
		if(turn_number == 1):
			life_remaining -= 1
		elif(turn_number == 2):
			life_remaining -= 2
		else:
			life_remaining -= 3
		#If we no longer have life left, its game over
		if(life_remaining <= 0):	
			print("0 LIFE REMAINING! GAME OVER")
		else:
			print("LIFE REMAINING: ", life_remaining)
	health_text.text = str(life_remaining)
