extends Node

#Dictionary containing all units
var dictionary = load("res://Scripts/Units/dictionary.gd")

var UI : CanvasLayer

var current_base_selected : Node2D

#Used to scale the crate when you hover of it
var crate_sprite : TextureButton
var crate_starting_size : Vector2

var base_locations : Array
func _ready():
	UI = find_child("UI")
	crate_sprite = find_child("base_button")
	crate_starting_size = crate_sprite.scale
	base_locations = UI.find_child("base_locations").get_children()
	select_units()
	
func select_units():
	var x = 0
	while x < base_locations.size():
		var dictionary_instance = dictionary.new()
		#Gets a random unit type
		var base = dictionary_instance.base_scenes[randi_range(0, dictionary_instance.base_scenes.size()-1)]
		
		#Instantiate unit
		var instance = base.instantiate()
		base_locations[x].add_child(instance)
		instance.global_position = base_locations[x].global_position
		x+=1
		
	#Opens the base chooser automatically on the first turn
	if(find_parent("game_manager").turn_number == 1):
		_on_base_button_pressed()
		

func _on_base_button_pressed() -> void:
	#Checks to see if a pressed event happened whilst the mouse was over the booster 
	if(!UI.visible):
		#Turn on the UI to purchase the booster
		UI.visible = true
		#Turn off the booster in the shop
		find_child("base_button").visible = false
		#play animation to pop the crate in
		get_node("AnimationPlayer").play("crate_appear")

func _on_close_button_pressed() -> void:
	#play animation to pop the crate out
	get_node("AnimationPlayer").play("crate_disappear")

func selected_unit(base, id):
	current_base_selected = base

func _on_buy_unit_button_pressed() -> void:
		#play animation to pop the crate out
		get_node("AnimationPlayer").play("crate_disappear")
		
func hide_base_options(hide : bool):
	var x = 0
	while x < base_locations.size():
		base_locations[x].get_child(0).find_child("base_button").visible = hide
		x+=1

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "crate_disappear" and UI.visible == true and current_base_selected):
		queue_free()
	elif(anim_name == "crate_disappear" and current_base_selected and current_base_selected.visible == true):
		current_base_selected.visible = false
		#Turn on booster in the shop
		find_child("base_button").visible = true
		UI.visible = false
	elif(anim_name == "crate_disappear"):
		#Turn on booster in the shop
		find_child("base_button").visible = true
		UI.visible = false

func _on_booster_button_mouse_entered() -> void:
	crate_sprite.scale = Vector2(crate_starting_size.x * 1.2, crate_starting_size.y * 1.2)

func _on_booster_button_mouse_exited() -> void:
	crate_sprite.scale = Vector2(crate_starting_size.x, crate_starting_size.y)
