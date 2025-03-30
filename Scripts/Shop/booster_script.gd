extends Node

#Dictionary containing all units
var dictionary = load("res://Scripts/Units/dictionary.gd")

var mouse_over : bool
var shop_manager : Node2D

var purchase_booster_UI : CanvasLayer
var choose_unit_UI : CanvasLayer
#Has the booster been bought
var bought : bool = false
@export var buy_cost : int

@export var potential_units_IDs : Array

var current_unit_selected : Node2D

func _ready():
	shop_manager = find_parent("shop_manager")
	purchase_booster_UI = find_child("purchase_booster_UI")
	choose_unit_UI = find_child("choose_unit_UI")
	select_units()
	
func select_units():
	var unit_locations = choose_unit_UI.find_child("unit_locations").get_children()
	var x = 0
	while x < unit_locations.size():
		var random_number = randi_range(0, potential_units_IDs.size())
		var dictionary_instance = dictionary.new()
		#Gets a random unit type
		var unit = dictionary_instance.item_scenes[random_number]
		
		#Instantiate unit
		var instance = unit.instantiate()
		unit_locations[x].add_child(instance)
		instance.unit_ID = random_number
		unit_locations[x].unit_ID = random_number
		unit_locations[x].unit = instance
		instance.position = Vector2(0,0)
		instance.disabled = true
		instance._ready()
		x+=1
		
func _on_area_2d__mouse_collision_mouse_entered() -> void:
	mouse_over = true

func _on_area_2d__mouse_collision_mouse_exited() -> void:
	mouse_over = false

func _input(event):
	if event is InputEventMouseButton:
		#Checks to see if something has happened with the left mouse button
		if event.button_index == MOUSE_BUTTON_LEFT:
			#Checks to see if a pressed event happened whilst the mouse was over the booster 
			if(mouse_over and event.pressed and !purchase_booster_UI.visible):
				#Turn on the UI to purchase the booster
				purchase_booster_UI.visible = true


func _on_buy_button_pressed() -> void:
	if(shop_manager.money >= buy_cost):
		#Spend the money required to buy the item
		shop_manager.change_money(buy_cost)
		#Turn off current UI and turn on UI to select a unit
		choose_unit_UI.visible = true
		purchase_booster_UI.visible = false

func _on_close_button_pressed() -> void:
	purchase_booster_UI.visible = false


func selected_unit(unit, id):
	current_unit_selected = unit


func _on_buy_unit_button_pressed() -> void:
	if(current_unit_selected != null):
		current_unit_selected.reparent(get_parent())
		current_unit_selected.disabled = false
		current_unit_selected.bought = true
		current_unit_selected.position = Vector2(0,0)
		current_unit_selected.cost_label.visible = false
		queue_free()
