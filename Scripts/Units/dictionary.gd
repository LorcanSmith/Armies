extends Node


# Dictionary to store unit IDs and their corresponding scene paths
var unit_scenes = {
	0: preload("res://Prefabs/Units/Level1/knight_unit.tscn"),
	1: preload("res://Prefabs/Units/Level1/wizard_unit.tscn")
}

var item_scenes = {
	0: preload("res://Prefabs/Shop Items/Common/knight_item.tscn"),
	1: preload("res://Prefabs/Shop Items/Common/wizard_item.tscn")
}
