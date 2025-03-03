extends Node


# Dictionary to store unit IDs and their corresponding scene paths
var unit_scenes = {
	#KNIGHT
	0: preload("res://Prefabs/Units/Level1/knight_unit.tscn"),
	1: preload("res://Prefabs/Units/Level1/wizard_unit.tscn"),
	#ARCHER
	3: preload("res://Prefabs/Units/Level1/archer_unit_LVL1.tscn"),
	4: preload("res://Prefabs/Units/Level2/archer_unit_LVL2.tscn"),
	5: preload("res://Prefabs/Units/Level3/archer_unit_LVL3.tscn")
}

var item_scenes = {
	#KNIGHT
	0: preload("res://Prefabs/Shop Items/Level1/knight_item.tscn"),
	1: preload("res://Prefabs/Shop Items/Level2/knight_level2_item.tscn"),
	#ARCHER
	3: preload("res://Prefabs/Shop Items/Level1/archer_item_LVL1.tscn"),
	4: preload("res://Prefabs/Shop Items/Level2/archer_item_LVL2.tscn"),
	5: preload("res://Prefabs/Shop Items/Level3/archer_item_LVL3.tscn")
}
