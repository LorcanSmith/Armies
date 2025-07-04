extends Node

#Unit dictionary, used to check unit types
var dictionary = preload("res://Scripts/Units/dictionary.gd")
var army : Array

var damage_buff : PackedScene = preload("res://Prefabs/Effects/Buffs/buff_damage.tscn")
var health_buff : PackedScene = preload("res://Prefabs/Effects/Buffs/buff_health.tscn")

var current_base_ID : int = -1
var base_sprite

var base_name : String = "House"
var base_description : String = "This base does nothing special but it's a great place to spend the winters!"

var base_sprites : Array = [
	preload("res://Sprites/Bases/castle.png"),
	preload("res://Sprites/Bases/bank.png"),
	preload("res://Sprites/Bases/tent.png"),
	preload("res://Sprites/Bases/hospital.png"),
	preload("res://Sprites/Bases/military_base_upgrade.png"),
	preload("res://Sprites/Bases/dragon_den_lowres.png"),
	preload("res://Sprites/Bases/default.png")
]

#Booleans for checks
var medieval_exclusive : bool = true
var army_exclusive : bool = true

var medieval_units : Array
var army_units : Array
var healer_units : Array

##Upgrading Bases
@export var base_upgrade_cost : int = 8
var tier : int = 0
var path_selected : int = 0
var upgrade_name_1 : String
var upgrade_name_2 : String

#Themes
var medieval_health : int = 0
var medieval_attack : int = 0
var army_health : int = 0
var army_attack : int = 0
var dinosaur_health : int = 0
#Types
var vehicle_health : int = 0
var vehicle_attack : int = 0
var human_health : int = 0
var human_attack : int = 0
var animal_health : int = 0
var animal_attack : int = 0

#Names
var soldier_health : int = 0
var soldier_attack : int = 0
var velociraptor_health : int = 0
var velociraptor_attack : int = 0

func _ready() -> void:
	base_sprite = find_child("base_sprite")
func set_base(id, n, d, play_anim : bool):
	if(id != -1):
		current_base_ID = id
		base_sprite.texture = base_sprites[id]
		base_sprite.get_child(0).texture = base_sprites[id]
		base_name = n
		base_description = d
		var gm = find_parent("game_manager")
		#Themes
		medieval_health = gm.medieval_health
		medieval_attack = gm.medieval_attack
		army_health = gm.army_health
		army_attack = gm.army_attack
		dinosaur_health = gm.dinosaur_health

		#Types
		vehicle_health = gm.vehicle_health
		vehicle_attack = gm.vehicle_attack
		human_health = gm.human_health
		human_attack = gm.human_attack
		animal_health = gm.animal_health
		animal_attack = gm.animal_attack

		#Names
		soldier_health = gm.soldier_health
		soldier_attack = gm.soldier_attack
		velociraptor_health = gm.velociraptor_health
		velociraptor_attack = gm.velociraptor_attack
		if(play_anim):
			get_node("AnimationPlayer").play("base_appear")
	
func start_of_turn():
	#Bank
	if(current_base_ID == 1):
		#Give 8 gold
		find_parent("shop_manager").change_money(-5)
	
func end_of_turn():
	var current_parent = get_parent()
	#Tell game manager what the current base is
	var gm = find_parent("game_manager")
	gm.base_ID = current_base_ID
	gm.base_name = base_name
	gm.base_description = base_description
	gm.base_sprite = base_sprites[current_base_ID]
	army = gm.army_units
	#Save current base stats
	#Themes
	gm.medieval_health = medieval_health
	gm.medieval_attack = medieval_attack
	gm.army_health = army_health
	gm.army_attack = army_attack
	gm.dinosaur_health = dinosaur_health
	#Types
	gm.vehicle_health = vehicle_health
	gm.vehicle_attack = vehicle_attack
	gm.human_health = human_health
	gm.human_attack = human_attack
	gm.animal_health = animal_health
	gm.animal_attack = animal_attack

	#Names
	gm.soldier_health = soldier_health
	gm.soldier_attack = soldier_attack
	gm.velociraptor_health = velociraptor_health
	gm.velociraptor_attack = velociraptor_attack
		
	check_units()
	
func check_units():
	var dictionary_instance = dictionary.new()
	var x = 0
	while x < army.size():
		var y = 0
		while y < army[x].size():
			if(army[x][y].units_on_tile.size() > 0):
				var unit = dictionary_instance.unit_scenes[army[x][y].units_on_tile[0].unit_ID].instantiate()
				##THEMES
				#Medieval
				if(unit.Medieval):
					if(medieval_health > 0):
						var instance = health_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",medieval_health)
						army[x][y].units_on_tile[0].health_boost += medieval_health
					if(medieval_attack > 0):
						var instance = damage_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",medieval_attack)
						army[x][y].units_on_tile[0].damage_boost += medieval_attack
				#Army
				if(unit.Army):
					pass
				#Dinsoaur
				if(unit.Dinosaur):
					pass
				##UNITS
				#Sheep
				if(unit.Sheep):
					army[x][y].units_on_tile[0].spawn_coin(army[x][y].units_on_tile[0].sell_cost)
				unit.queue_free()
			y += 1
		x+= 1

func _on_base_area_2d_mouse_entered() -> void:
	get_parent().find_child("Tooltip").update_base_tooltip(current_base_ID,base_name, base_description)

#SHOW BASE UPGRADES
func _on_base_upgrade_button_pressed() -> void:
	#Play popin animation
	get_node("base_upgrade_options/base_anim_player").play("popin")
	#Set text for the tier
	find_child("tier_text").text = ("Current Tier: " + str(tier))
	#turn on upgrade UI
	find_child("base_upgrade_options").visible = true
	#turn off upgrade button
	find_child("base_upgrade_button").visible = false
	var upgrade_path_1_text = find_child("path_1_text")
	var upgrade_path_1_desc = find_child("path_1_desc")
	var upgrade_path_2_text = find_child("path_2_text")
	var upgrade_path_2_desc = find_child("path_2_desc")
	#set upgrade path names
	#Castle
	if(current_base_ID == 0):
		var castle_path_1_names = ["Shields", "Fortifications"]
		var castle_path_1_descs = ["+1 health to medieval units", "+2 health to medieval units"]
		var castle_path_2_names = ["Blacksmith Training", "Formation Training"]
		var castle_path_2_descs = ["+1 attack to medieval units", "+2 attack to medieval units"]
		
		upgrade_path_1_text.text = castle_path_1_names[tier]
		upgrade_path_1_desc.text = castle_path_1_descs[tier]
		upgrade_path_2_text.text = castle_path_2_names[tier]
		upgrade_path_2_desc.text = castle_path_2_descs[tier]
#SET BASE UPGRADE
func _on_confirm_base_upgrade_pressed() -> void:
	var shop_manager = find_parent("shop_manager")
	#Check if you have enough money
	if(shop_manager.money > base_upgrade_cost):
		shop_manager.change_money(base_upgrade_cost)
		#Path 1
		if(path_selected == 1):
			#Tier 0
			if(tier == 0):
				#Castle
				if(current_base_ID == 0):
					medieval_health += 1
				#Bank
				elif(current_base_ID == 1):
					pass
				#Tent
				elif(current_base_ID == 2):
					pass
				#Hospital
				elif(current_base_ID == 3):
					pass
			#Tier 1
			elif(tier == 1):
				#Castle
				if(current_base_ID == 0):
					medieval_health += 1
				#Bank
				elif(current_base_ID == 1):
					pass
				#Tent
				elif(current_base_ID == 2):
					pass
				#Hospital
				elif(current_base_ID == 3):
					pass
			#Tier 2
			elif(tier == 2):
				#Castle
				if(current_base_ID == 0):
					medieval_health += 1
				#Bank
				elif(current_base_ID == 1):
					pass
				#Tent
				elif(current_base_ID == 2):
					pass
				#Hospital
				elif(current_base_ID == 3):
					pass
		#Path 2
		elif(path_selected == 2):
			#Tier 0
			if(tier == 0):
				#Castle
				if(current_base_ID == 0):
					medieval_health += 1
				#Bank
				elif(current_base_ID == 1):
					pass
				#Tent
				elif(current_base_ID == 2):
					pass
				#Hospital
				elif(current_base_ID == 3):
					pass
			#Tier 1
			elif(tier == 1):
				#Castle
				if(current_base_ID == 0):
					medieval_health += 1
				#Bank
				elif(current_base_ID == 1):
					pass
				#Tent
				elif(current_base_ID == 2):
					pass
				#Hospital
				elif(current_base_ID == 3):
					pass
			#Tier 2
			elif(tier == 2):
				#Castle
				if(current_base_ID == 0):
					medieval_health += 1
				#Bank
				elif(current_base_ID == 1):
					pass
				#Tent
				elif(current_base_ID == 2):
					pass
				#Hospital
				elif(current_base_ID == 3):
					pass
		#Play popout animation
		get_node("base_upgrade_options/base_anim_player").play("popout")
	#Not enough money, play animation to indicate this
	else:
		pass
func _on_path_1_pressed() -> void:
	path_selected = 1
func _on_path_2_pressed() -> void:
	path_selected = 2
func _on_close_button_pressed() -> void:
	#Turn off UI
	find_child("base_upgrade_options").visible = false
	#Turn on upgrade_button
	find_child("base_upgrade_button").visible = true
func _on_base_anim_player_animation_finished(anim_name: StringName) -> void:
	#Turn off UI
	if(anim_name == "popout"):
		find_child("base_upgrade_options").visible = false
		#Turn on upgrade_button
		find_child("base_upgrade_button").visible = true
