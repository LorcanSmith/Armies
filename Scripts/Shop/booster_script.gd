extends Node

#Dictionary containing all units
var dictionary = load("res://Scripts/Units/dictionary.gd")

var shop_manager : Node2D

var purchase_booster_UI : CanvasLayer
var choose_unit_UI : CanvasLayer

@export var booster_name : String
@export var booster_description : String
@export var booster_image : Texture2D

#Has the booster been bought
var bought : bool = false
@export var buy_cost : int

@export var potential_units_IDs : Array

var current_unit_selected : Node2D

func _ready():
	shop_manager = find_parent("shop_manager")
	purchase_booster_UI = find_child("purchase_booster_UI")
	choose_unit_UI = find_child("choose_unit_UI")
	
	find_child("booster_name").text = booster_name
	find_child("booster_description").text = booster_description
	find_child("booster_image").texture = booster_image
	find_child("Cost").text = str(buy_cost)
	find_child("cost_on_button").text = str(buy_cost)
	select_units()
	
func select_units():
	var unit_locations = choose_unit_UI.find_child("unit_locations").get_children()
	var x = 0
	while x < unit_locations.size():
		var random_number = potential_units_IDs[randi_range(0, potential_units_IDs.size()-1)]
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
		instance.cost_label.visible = false
		instance._ready()
		x+=1
		

func _on_booster_button_pressed() -> void:
	#Checks to see if a pressed event happened whilst the mouse was over the booster 
	if(!purchase_booster_UI.visible):
		#Turn on the UI to purchase the booster
		purchase_booster_UI.visible = true
		#Turn off the booster in the shop
		find_child("booster_button").visible = false
		#play animation to pop the crate in
		get_node("AnimationPlayer").play("crate_appear")

func _on_buy_button_pressed() -> void:
	if(shop_manager.money >= buy_cost):
		#Spend the money required to buy the item
		shop_manager.change_money(buy_cost)
		#Turn off current UI and turn on UI to select a unit
		choose_unit_UI.visible = true
		purchase_booster_UI.visible = false
		#play animation to pop the crate in
		get_node("AnimationPlayer").play("crate_appear")

func _on_close_button_pressed() -> void:
	#play animation to pop the crate out
	get_node("AnimationPlayer").play("crate_disappear")

func selected_unit(unit, id):
	current_unit_selected = unit
	if(find_child("buy_unit_button").visible == false):
		find_child("buy_unit_button").visible = true

func _on_buy_unit_button_pressed() -> void:
		#play animation to pop the crate out
		get_node("AnimationPlayer").play("crate_disappear")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "crate_disappear" and purchase_booster_UI.visible == false):
		current_unit_selected.reparent(get_parent())
		current_unit_selected.disabled = false
		current_unit_selected.bought = true
		current_unit_selected.position = Vector2(0,0)
		current_unit_selected.scale = Vector2(1,1)
		current_unit_selected.cost_label.visible = false
		queue_free()
	elif(anim_name == "crate_disappear" and purchase_booster_UI.visible == true):
		purchase_booster_UI.visible = false
		#Turn on booster in the shop
		find_child("booster_button").visible = true
