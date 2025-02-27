extends Node2D

# swaps between the battle and shop scene
@export var CombatManager : Node2D
@export var ShopManager : Node2D
var current_scene : Node2D

var army : Array

var shop_scene = preload("res://Scenes/Test Scenes/Shop.tscn")

func _ready():
	enter_shop()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		enter_combat()

func enter_shop():
	current_scene = shop_scene.instantiate()
	add_child(current_scene)
	
func enter_combat():
	print("moved to combat")
