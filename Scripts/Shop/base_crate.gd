extends Node

var selected_base : bool = false

#Dictionary containing all units
var dictionary = load("res://Scripts/Units/dictionary.gd")

var UI : CanvasLayer

var current_base_selected : Node2D

#Used to scale the crate when you hover of it
var crate_sprite : TextureButton
var crate_starting_size : Vector2

var base_locations : Array

var base_manager : Node2D
func _ready():
	base_manager = find_parent("shop_manager").find_child("base_manager")
	UI = find_child("UI")
	crate_sprite = find_child("base_button")
	crate_starting_size = crate_sprite.scale
	base_locations = UI.find_child("base_locations").get_children()
	select_bases()
	
func select_bases():
	var x = 0
	while x < base_locations.size():
		var dictionary_instance = dictionary.new()
		seed(find_parent("game_manager").seed * find_parent("game_manager").turn_number * (x+1))
		var random_base_percentage = randf_range(0,100)/100
		var base_pos = int(round((dictionary_instance.base_scenes.size()-1) * random_base_percentage))
		#Gets a random unit type
		var base = dictionary_instance.base_scenes[base_pos]
		
		#Instantiate unit
		var instance = base.instantiate()
		base_locations[x].add_child(instance)
		instance.global_position = base_locations[x].global_position
		x+=1
		
	#Opens the base chooser automatically on the first turn
	if(find_parent("game_manager").turn_number == 1):
		_on_base_button_pressed()
		

func _on_base_button_pressed() -> void:
	find_child("Container").scale = Vector2(0,0)
	#Turn on the UI to purchase the booster
	UI.visible = true
	#play animation to pop base crate in shop out
	get_node("AnimationPlayer2").stop()
	get_node("AnimationPlayer2").play("base_button_disappear")
	

func _on_close_button_pressed() -> void:
	#play animation to pop the crate out
	get_node("AnimationPlayer").play("crate_disappear")
	find_child("buy_base_button").visible = false
	find_parent("shop_manager").find_child("Tooltip").get_node("AnimationPlayer").play("tooltip_popout")

func _on_buy_base_button_pressed() -> void:
	#play animation to pop the crate out
	get_node("AnimationPlayer").play("crate_disappear")
	base_manager.set_base(current_base_selected.base_id, current_base_selected.base_name, current_base_selected.description, true)
	selected_base = true
	find_parent("shop_manager").find_child("Tooltip").get_node("AnimationPlayer").play("tooltip_popout")

func set_current_base(base):
	current_base_selected = base
	find_child("buy_base_button").visible = true
	
func hide_base_options(hide : bool):
	var x = 0
	while x < base_locations.size():
		base_locations[x].get_child(0).find_child("base_button").visible = hide
		x+=1

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "crate_disappear" and selected_base):
		queue_free()
	elif(anim_name == "crate_disappear"):
		#Turn on booster in the shop
		crate_sprite.visible = true
		crate_sprite.scale = Vector2(0,0)
		get_node("AnimationPlayer2").play("base_button_appear")
		UI.visible = false
	if(anim_name == "base_button_disappear"):
		#Turn off the booster in the shop
		crate_sprite.visible = false
		#play animation to pop the crate in
		find_child("Container").scale = Vector2(0,0)
		get_node("AnimationPlayer").play("crate_appear")
	elif(anim_name == "base_button_appear"):
		get_node("AnimationPlayer2").play("pulse")
	

func _on_booster_button_mouse_entered() -> void:
	get_node("AnimationPlayer2").stop()
	crate_sprite.scale = Vector2(crate_starting_size.x * 1.2, crate_starting_size.y * 1.2)

func _on_booster_button_mouse_exited() -> void:
	crate_sprite.scale = Vector2(crate_starting_size.x, crate_starting_size.y)
	if(!get_node("AnimationPlayer2").is_playing()):
		get_node("AnimationPlayer2").play("pulse")
