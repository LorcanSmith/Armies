extends Node2D

# swaps between the battle and shop scene
@export var CombatManager : Node2D
@export var ShopManager : Node2D
var current_scene : Node2D

var army : Array

var shop_scene = preload("res://Scenes/Test Scenes/Shop.tscn")
var combat_scene = preload("res://Scenes/Test Scenes/Combat.tscn")

var in_combat : bool = false

func _ready():
	in_combat = false
	create_scene()
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		swap_scenes()
		create_scene()
		
func swap_scenes():
	#	reverses the value of in_combat boolean
	in_combat = !in_combat
	
	current_scene.queue_free()
	print("in_combat = ", in_combat)
	
func create_scene():
	if in_combat:
		current_scene = combat_scene.instantiate()
	else:
		current_scene = shop_scene.instantiate()
	add_child(current_scene)
		
