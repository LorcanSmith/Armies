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

func _ready():
	in_combat = false
	create_scene()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		for grids in GridManager.get_children():
			grids.save_current_grid()
		swap_scenes()
		
		
func send_enemy_army() -> Array:
	return Array()
		
func swap_scenes():
	#reverses the value of in_combat boolean
	in_combat = !in_combat
	current_scene.queue_free()
	create_scene()
	
func create_scene():
	if in_combat:
		current_scene = combat_scene.instantiate()
	else:
		current_scene = shop_scene.instantiate()
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
	if Input.is_key_pressed(KEY_S):
		for grids in GridManager.get_children():
			grids.save_current_grid()
	if Input.is_key_pressed(KEY_L):
		GridManager.load_layout("army")
	if Input.is_key_pressed(KEY_T):
		if (CombatManager!= null):
			CombatManager.battle_ticker()
