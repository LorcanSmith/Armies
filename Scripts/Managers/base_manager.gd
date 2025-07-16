extends Node

#Unit dictionary, used to check unit types
var dictionary = preload("res://Scripts/Units/dictionary.gd")
var army : Array
var tooltip : Node2D
var damage_buff : PackedScene = preload("res://Prefabs/Effects/Buffs/buff_damage.tscn")
var health_buff : PackedScene = preload("res://Prefabs/Effects/Buffs/buff_health.tscn")
var negative_health_buff : PackedScene = preload("res://Prefabs/Effects/Buffs/negative_buff_health.tscn")

var current_base_ID : int = -1
var base_sprite

var base_name : String = "House"

var base_sprites : Array = [
	preload("res://Sprites/Bases/castle.png"),
	preload("res://Sprites/Bases/bank.png"),
	preload("res://Sprites/Bases/military_base_upgrade.png"),
	preload("res://Sprites/Bases/hospital.png"),
	preload("res://Sprites/Bases/barn.png"),
	preload("res://Sprites/Bases/default.png")
]

#Booleans for checks
var medieval_exclusive : bool = true
var army_exclusive : bool = true

var medieval_units : Array
var army_units : Array
var healer_units : Array
var animal_units : Array

##Upgrading Bases
#Section in the shop that contains the upgrade paths
var base_section : Node2D
@export var base_upgrade_cost : int = 8
var tier : int = 3
var path_selected : int = 0
var upgrade_name_1 : String
var upgrade_name_2 : String

#Special
var base_description : String = "This base does nothing special but it's a great place to spend the winters!"
var extra_money : int = 0
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
var healer_health : int = 0
var healer_attack : int = 0
#Names
var soldier_health : int = 0
var soldier_attack : int = 0
var velociraptor_health : int = 0
var velociraptor_attack : int = 0

func _ready() -> void:
	base_sprite = find_child("base_sprite")
	tooltip = get_parent().find_child("Tooltip")
	base_section = find_parent("shop_manager").find_child("base_section")

func set_base(id, n, d, play_anim : bool):
	if(id != -1):
		current_base_ID = id
		base_sprite.texture = base_sprites[id]
		base_sprite.get_child(0).texture = base_sprites[id]
		base_name = n
		var gm = find_parent("game_manager")
		tier = gm.tier
		#Special
		base_description = d
		extra_money = gm.extra_money
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
		healer_health = gm.healer_health
		healer_attack = gm.healer_attack
		#Names
		soldier_health = gm.soldier_health
		soldier_attack = gm.soldier_attack
		velociraptor_health = gm.velociraptor_health
		velociraptor_attack = gm.velociraptor_attack
		
		if(play_anim):
			get_node("AnimationPlayer").play("base_appear")
			tier = 0
func start_of_turn():
	#Bank
	if(current_base_ID == 1):
		#Give extra gold
		find_parent("shop_manager").change_money(-extra_money)
	
func end_of_turn():
	var current_parent = get_parent()
	#Tell game manager what the current base is
	var gm = find_parent("game_manager")
	gm.tier = tier
	gm.base_ID = current_base_ID
	gm.base_name = base_name
	gm.base_description = base_description
	gm.base_sprite = base_sprites[current_base_ID]
	army = gm.army_units
	#Save current base stats
	#Special
	gm.extra_money = extra_money
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
	gm.healer_health = healer_health
	gm.healer_attack = healer_attack
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
					if(medieval_health > 0 or medieval_health < 0):
						var instance 
						if(medieval_health > 0):
							instance = health_buff.instantiate()
						elif(medieval_health < 0):
							instance = negative_health_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",medieval_health)
						army[x][y].units_on_tile[0].buff_unit_health(medieval_health)
					if(medieval_attack > 0):
						var instance = damage_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",medieval_attack)
						army[x][y].units_on_tile[0].buff_unit_damage(medieval_attack)
				#Army
				if(unit.Army):
					if(army_health > 0 or army_health < 0):
						var instance 
						if(army_health > 0):
							instance = health_buff.instantiate()
						elif(army_health < 0):
							instance = negative_health_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",army_health)
						army[x][y].units_on_tile[0].buff_unit_health(army_health)
					if(army_attack > 0):
						var instance = damage_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",army_attack)
						army[x][y].units_on_tile[0].buff_unit_damage(army_attack)
				#Dinsoaur
				if(unit.Dinosaur):
					pass
				##TYPES
				#Healer
				if(unit.Healer):
					if(healer_health > 0 or healer_health < 0):
						var instance 
						if(healer_health > 0):
							instance = health_buff.instantiate()
						elif(healer_health < 0):
							instance = negative_health_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",healer_health)
						army[x][y].units_on_tile[0].buff_unit_health(healer_health)
					if(healer_attack > 0):
						var instance = damage_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",healer_attack)
						army[x][y].units_on_tile[0].buff_unit_damage(healer_attack)
				#Animal
				if(unit.Animal):
					if(animal_health > 0 or animal_health < 0):
						var instance 
						if(animal_health > 0):
							instance = health_buff.instantiate()
						elif(animal_health < 0):
							instance = negative_health_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",animal_health)
						army[x][y].units_on_tile[0].buff_unit_health(animal_health)
					if(animal_attack > 0):
						var instance = damage_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",animal_attack)
						army[x][y].units_on_tile[0].buff_unit_damage(animal_attack)
				##UNITS
				#Sheep
				if(unit.Sheep):
					army[x][y].units_on_tile[0].spawn_coin(army[x][y].units_on_tile[0].sell_cost)
				unit.queue_free()
			y += 1
		x+= 1

func _on_base_area_2d_mouse_entered() -> void:
	tooltip.update_base_tooltip(current_base_ID,base_name, base_description)

#SHOW BASE UPGRADES
func update_base_upgrade_paths() -> void:
	#Turn off tooltip
	tooltip.get_node("AnimationPlayer").play("tooltip_popout")
	
	#Update text
	#Set text for the tier
	base_section.find_child("tier_text").text = ("Current Tier: " + str(tier))
	var upgrade_path_1_text = base_section.find_child("path_1_text")
	var upgrade_path_1_desc = base_section.find_child("path_1_desc")
	var upgrade_path_2_text = base_section.find_child("path_2_text")
	var upgrade_path_2_desc = base_section.find_child("path_2_desc")
	#If max tier, don't allow any more upgrades
	if(tier > 2):
		base_section.find_child("path_1").visible = false
		base_section.find_child("path_2").visible = false
		base_section.find_child("max_tier").visible = true
		base_section.find_child("max_tier_desc").text = base_description
		base_section.find_child("confirm_base_upgrade").visible = false
	else:
		base_section.find_child("path_1").visible = true
		base_section.find_child("path_2").visible = true
		base_section.find_child("max_tier").visible = false
		base_section.find_child("confirm_base_upgrade").visible = true
	
	var current_path_1_name_array : Array
	var current_path_1_desc_array : Array
	var current_path_2_name_array : Array
	var current_path_2_desc_array : Array
	#set upgrade path names
	if(tier != 3):
		#Castle
		if(current_base_ID == 0):
			current_path_1_name_array = ["Shields", "Fortifications", "Tight Formations"]
			current_path_1_desc_array = ["Gives +1 health to medieval units at end of turn", "Gives +2 health to medieval units at end of turn", "Gives +3 health to medieval units at end of turn"]
			
			current_path_2_name_array = ["Blacksmith Training", "Attack Training", "Flanking Tactics"]
			current_path_2_desc_array = ["Gives +1 attack to medieval units at end of turn", "Gives +2 attack to medieval units at end of turn", "Gives +3 attack to medieval units at end of turn"]
			
		#Bank
		elif(current_base_ID == 1):
			current_path_1_name_array = ["Pocket Money", "Investments", "Lottery Tickets"]
			current_path_1_desc_array = ["Gain an extra +3 gold each turn", "Gain an extra +6 gold each turn", "Gain an extra +10 gold each turn"]
			
			current_path_2_name_array = ["Long Term Goals", "Re-investments", "Dividends"]
			current_path_2_desc_array = ["Does nothing YET", "Patience pays off", "Gain an extra + 15 gold each turn"]
		#Army Tent
		elif(current_base_ID == 2):
			current_path_1_name_array = ["Reinforcements", "Extensive Training", "Mandatory Service"]
			current_path_1_desc_array = ["Army units gain +1 health at the end of turn", "Army units gain +2 health and +1 attack at the end of turn", "Army units gain +4 health and +2 attack at the end of turn"]
			
			current_path_2_name_array = ["Fighting Spirit", "Better Guns", "Fight till the death"]
			current_path_2_desc_array = ["Army units gain +1 attack at the end of turn", "Army units gain +2 attack and +1 health at the end of turn", "Army units gain +4 attack and +2 health at the end of turn"]
		#Hospital
		elif(current_base_ID == 3):
			current_path_1_name_array = ["Medical Supplies", "Highly Qualified Doctors", "Government Funding"]
			current_path_1_desc_array = ["Gives Healers +2 health at the end of the turn", "Gives Healers +4 health at the end of turn", "Gives Healers +6 health and +1 attack at the end of the turn"]
			
			current_path_2_name_array = ["Field Hospital","Resourceful Medics", "Combat Medics"]
			current_path_2_desc_array = ["Gives Healers +1 attack and +1 health at the end of the turn", "Gives Healers +4 attack at the end of turn", "Gives Healers +6 attack and +1 health at the end of the turn"]
		#Barn
		elif(current_base_ID == 4):
			current_path_1_name_array = ["Free Range", "Petting Zoo", "Animal Sanctuary"]
			current_path_1_desc_array = ["Gives Animals +1 health at the end of turn", "Gives Animals +2 health at the end of turn", "Gives Animals +4 health at the end of turn"]
			
			current_path_2_name_array = ["Food Supplements", "Indoor Farm", "Factory Farming"]
			current_path_2_desc_array = ["Gives Animals +1 attack at the end of turn", "Gives Animals +3 attack and -1 health at the end of turn", "Gives Animals +6 attack and -3 health at the end of the turn"]
		
		
		
		upgrade_path_1_text.text = current_path_1_name_array[tier]
		upgrade_path_1_desc.text = current_path_1_desc_array[tier]
		upgrade_path_2_text.text = current_path_2_name_array[tier]
		upgrade_path_2_desc.text = current_path_2_desc_array[tier]
#SET BASE UPGRADE
func _on_confirm_base_upgrade_pressed() -> void:
	var shop_manager = find_parent("shop_manager")
	#Check if you have enough money
	if(shop_manager.money > base_upgrade_cost):
		shop_manager.change_money(base_upgrade_cost)
		tier += 1
		#Path 1
		if(path_selected == 1):
			#Tier 1
			if(tier == 0):
				#Castle
				if(current_base_ID == 0):
					medieval_health = 1
				#Bank
				elif(current_base_ID == 1):
					extra_money = 3
				#Army Tent
				elif(current_base_ID == 2):
					army_health = 1
				#Hospital
				elif(current_base_ID == 3):
					healer_health = 2
				#Barn
				elif(current_base_ID == 4):
					animal_health = 1
			#Tier 2
			elif(tier == 1):
				#Castle
				if(current_base_ID == 0):
					medieval_attack = 2
				#Bank
				elif(current_base_ID == 1):
					extra_money = 6
				#Army Tent
				elif(current_base_ID == 2):
					army_health = 2
					army_attack = 1
				#Hospital
				elif(current_base_ID == 3):
					healer_health = 4
				#Barn
				elif(current_base_ID == 4):
					animal_health = 2
			#Tier 3
			elif(tier == 2):
				#Castle
				if(current_base_ID == 0):
					medieval_health = 3
				#Bank
				elif(current_base_ID == 1):
					extra_money = 10
				#Tent
				elif(current_base_ID == 2):
					army_health = 4
					army_attack = 2
				#Hospital
				elif(current_base_ID == 3):
					healer_health = 6
					healer_attack = 1
				#Barn
				elif(current_base_ID == 4):
					animal_health = 4
		#Path 2
		elif(path_selected == 2):
			#Tier 0
			if(tier == 0):
				#Castle
				if(current_base_ID == 0):
					medieval_attack = 1
				#Bank
				elif(current_base_ID == 1):
					pass
				#Army Tent
				elif(current_base_ID == 2):
					army_attack = 1
				#Hospital
				elif(current_base_ID == 3):
					healer_attack = 2
				#Barn
				elif(current_base_ID == 4):
					animal_attack = 1
			#Tier 1
			elif(tier == 1):
				#Castle
				if(current_base_ID == 0):
					medieval_attack = 2
				#Bank
				elif(current_base_ID == 1):
					pass
				#Army Tent
				elif(current_base_ID == 2):
					army_attack = 2
					army_health = 1
				#Hospital
				elif(current_base_ID == 3):
					healer_attack = 4
				#Barn
				elif(current_base_ID == 4):
					animal_attack = 3
					animal_health = -1
			#Tier 2
			elif(tier == 2):
				#Castle
				if(current_base_ID == 0):
					medieval_attack = 3
				#Bank
				elif(current_base_ID == 1):
					extra_money = 15
				#Army Tent
				elif(current_base_ID == 2):
					army_attack = 4
					army_health = 2
				#Hospital
				elif(current_base_ID == 3):
					healer_attack = 6
					healer_health = 1
				#Barn
				elif(current_base_ID == 4):
					animal_attack = 6
					animal_health = -3
	#Not enough money, play animation to indicate this
	else:
		pass
	update_base_upgrade_paths()
	untoggle_buttons()
func _on_path_1_pressed() -> void:
	path_selected = 1
	base_description = base_section.find_child("path_1_desc").text
func _on_path_2_pressed() -> void:
	path_selected = 2
	base_description = base_section.find_child("path_2_desc").text
	
func untoggle_buttons():
	base_section.find_child("path_1").button_pressed = false
	base_section.find_child("path_2").button_pressed = false
