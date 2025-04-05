extends Node

#Unit dictionary, used to check unit types
var dictionary = preload("res://Scripts/Units/dictionary.gd")
var army : Array

var damage_buff : PackedScene = preload("res://Prefabs/Effects/Buffs/buff_damage.tscn")
var health_buff : PackedScene = preload("res://Prefabs/Effects/Buffs/buff_health.tscn")

var current_base_ID : int = -1
var base_sprite

var base_name : String
var base_description : String

var base_sprites : Array = [
	preload("res://Sprites/Bases/castle.png"),
	preload("res://Sprites/Bases/bank.png"),
	preload("res://Sprites/Bases/tent.png")
]

#Booleans for checks
var medieval_exclusive : bool = true
var army_exclusive : bool = true

func _ready() -> void:
	base_sprite = find_child("base_sprite")
func set_base(id, n, d):
	current_base_ID = id
	base_sprite.texture = base_sprites[id]
	base_sprite.get_child(0).texture = base_sprites[id]
	base_name = n
	base_description = d
	
func start_of_turn():
	#Bank
	if(current_base_ID == 1):
		#Give 8 gold
		find_parent("shop_manager").change_money(-8)

func end_of_turn():
	var current_parent = get_parent()
	#Tell game manager what the current base is
	var gm = find_parent("game_manager")
	gm.base_ID = current_base_ID
	gm.base_name = base_name
	gm.base_description = base_description
	gm.base_sprite = base_sprites[current_base_ID]
	army = gm.army_units
	set_bools()
	
	#Castle
	if(current_base_ID == 0):
		#Give medieval units +1 health if no other unit type exists
		if(medieval_exclusive):
			var x = 0
			while x < army.size():
				var y = 0
				while y < army[x].size():
					if(army[x][y].units_on_tile.size() > 0):
						var instance = health_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",1)
						army[x][y].units_on_tile[0].health_boost += 1
					y += 1
				x += 1
	if(current_base_ID == 2):
		#Give medieval units +1 health if no other unit type exists
		if(army_exclusive):
			var x = 0
			while x < army.size():
				var y = 0
				while y < army[x].size():
					if(army[x][y].units_on_tile.size() > 0):
						var instance = damage_buff.instantiate()
						instance.global_position = self.global_position
						instance.unit = army[x][y].units_on_tile[0]
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(instance)
						instance.find_child("buff_text").text = str("+",1)
						army[x][y].units_on_tile[0].damage_boost += 1
					y += 1
				x += 1
func set_bools():
	var dictionary_instance = dictionary.new()
	var x = 0
	while x < army.size():
		var y = 0
		while y < army[x].size():
			if(army[x][y].units_on_tile.size() > 0):
				var unit = dictionary_instance.unit_scenes[army[x][y].units_on_tile[0].unit_ID].instantiate()
				if(!unit.Medieval):
					medieval_exclusive = false
				if(!unit.Army):
					army_exclusive = false
				else:
					print(unit.Army)
				unit.queue_free()
			y += 1
		x+= 1

func _on_area_2d_mouse_entered() -> void:
	get_parent().find_child("Tooltip").update_base_tooltip(current_base_ID,base_name, base_description)
