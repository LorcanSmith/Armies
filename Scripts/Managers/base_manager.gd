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
	preload("res://Sprites/Bases/default.png")
]

#Booleans for checks
var medieval_exclusive : bool = true
var army_exclusive : bool = true

var medieval_units : Array
var army_units : Array
var healer_units : Array

func _ready() -> void:
	base_sprite = find_child("base_sprite")
func set_base(id, n, d, play_anim : bool):
	if(id != -1):
		current_base_ID = id
		base_sprite.texture = base_sprites[id]
		base_sprite.get_child(0).texture = base_sprites[id]
		base_name = n
		base_description = d
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
	check_units()
	#Castle
	if(current_base_ID == 0):
		#Give medieval units +1 health
		var x = 0
		while x < medieval_units.size():
			#Delay so the buffs don't all appear at the same time
			await get_tree().create_timer(randf_range(0.05, 0.25)).timeout
			var instance = health_buff.instantiate()
			instance.global_position = self.global_position
			instance.unit = medieval_units[x]
			find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
			instance.find_child("buff_text").text = str("+",1)
			medieval_units[x].health_boost += 1
			x += 1
	if(current_base_ID == 2):
		#Give army units +1 attack
			var x = 0
			while x < army_units.size():
				#Delay so the buffs don't all appear at the same time
				await get_tree().create_timer(randf_range(0.05, 0.25)).timeout
				var instance = damage_buff.instantiate()
				instance.global_position = self.global_position
				instance.unit = army_units[x]
				find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
				instance.find_child("buff_text").text = str("+",1)
				army_units[x].damage_boost += 1
				x += 1
	#Hospital
	if(current_base_ID == 3):
		#Give healers +2 health
		var x = 0
		while x < healer_units.size():
			#Delay so the buffs don't all appear at the same time
			await get_tree().create_timer(randf_range(0.05, 0.25)).timeout
			var instance = health_buff.instantiate()
			instance.global_position = self.global_position
			instance.unit = healer_units[x]
			find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
			instance.find_child("buff_text").text = str("+",2)
			healer_units[x].health_boost += 2
			x += 1
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
				if(!unit.Medieval):
					medieval_exclusive = false
				else:
					medieval_units.append(army[x][y].units_on_tile[0])
				#Army
				if(!unit.Army):
					army_exclusive = false
				else:
					army_units.append(army[x][y].units_on_tile[0])
				if(unit.Healer):
					healer_units.append(army[x][y].units_on_tile[0])
				##UNITS
				#Sheep
				if(unit.Sheep):
					army[x][y].units_on_tile[0].spawn_coin(army[x][y].units_on_tile[0].sell_cost)
				unit.queue_free()
			y += 1
		x+= 1

func _on_base_area_2d_mouse_entered() -> void:
	get_parent().find_child("Tooltip").update_base_tooltip(current_base_ID,base_name, base_description)
