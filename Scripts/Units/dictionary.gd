extends Node


# Dictionary to store unit IDs and their corresponding scene paths
var unit_scenes = {
	#KNIGHT
	0: preload("res://Prefabs/Units/Level1/knight_unit_LVL1.tscn"),
	1: preload("res://Prefabs/Units/Level2/knight_unit_LVL2.tscn"),
	2: preload("res://Prefabs/Units/Level3/knight_unit_LVL3.tscn"),
	#ARCHER
	3: preload("res://Prefabs/Units/Level1/archer_unit_LVL1.tscn"),
	4: preload("res://Prefabs/Units/Level2/archer_unit_LVL2.tscn"),
	5: preload("res://Prefabs/Units/Level3/archer_unit_LVL3.tscn"),
	#Catapult
	6: preload("res://Prefabs/Units/Level1/catapult_unit_LVL1.tscn"),
	7: preload("res://Prefabs/Units/Level2/catapult_unit_LVL2.tscn"),
	8: preload("res://Prefabs/Units/Level3/catapult_unit_LVL3.tscn"),
	#Tank
	9: preload("res://Prefabs/Units/Level1/tank_unit_LVL1.tscn"),
	10: preload("res://Prefabs/Units/Level2/tank_unit_LVL2.tscn"),
	11: preload("res://Prefabs/Units/Level3/tank_unit_LVL3.tscn"),
	#Soldier
	12: preload("res://Prefabs/Units/Level1/soldier_unit_LVL1.tscn"),
	13: preload("res://Prefabs/Units/Level2/soldier_unit_LVL2.tscn"),
	14: preload("res://Prefabs/Units/Level3/soldier_unit_LVL3.tscn"),
	#Medic
	15: preload("res://Prefabs/Units/Level1/medic_unit_LVL1.tscn"),
	16: preload("res://Prefabs/Units/Level2/medic_unit_LVL2.tscn"),
	17: preload("res://Prefabs/Units/Level3/medic_unit_LVL3.tscn"),
	#Polearm
	18: preload("res://Prefabs/Units/Level1/polearm_unit_LVL1.tscn"),
	19: preload("res://Prefabs/Units/Level2/polearm_unit_LVL2.tscn"),
	20: preload("res://Prefabs/Units/Level3/polearm_unit_LVL3.tscn"),
	#Sniper
	21: preload("res://Prefabs/Units/Level1/sniper_unit_LVL1.tscn"),
	22: preload("res://Prefabs/Units/Level2/sniper_unit_LVL2.tscn"),
	23: preload("res://Prefabs/Units/Level3/sniper_unit_LVL3.tscn")
}

var item_scenes = {
	#KNIGHT
	0: preload("res://Prefabs/Shop Items/Level1/knight_item_LVL1.tscn"),
	1: preload("res://Prefabs/Shop Items/Level2/knight_item_LVL2.tscn"),
	2: preload("res://Prefabs/Shop Items/Level3/knight_item_LVL3.tscn"),
	#ARCHER
	3: preload("res://Prefabs/Shop Items/Level1/archer_item_LVL1.tscn"),
	4: preload("res://Prefabs/Shop Items/Level2/archer_item_LVL2.tscn"),
	5: preload("res://Prefabs/Shop Items/Level3/archer_item_LVL3.tscn"),
	#Catapult
	6: preload("res://Prefabs/Shop Items/Level1/catapult_item_LVL1.tscn"),
	7: preload("res://Prefabs/Shop Items/Level2/catapult_item_LVL2.tscn"),
	8: preload("res://Prefabs/Shop Items/Level3/catapult_item_LVL3.tscn"),
	#Tank
	9: preload("res://Prefabs/Shop Items/Level1/tank_item_LVL1.tscn"),
	10: preload("res://Prefabs/Shop Items/Level2/tank_item_LVL2.tscn"),
	11: preload("res://Prefabs/Shop Items/Level3/tank_item_LVL3.tscn"),
	#Soldier
	12: preload("res://Prefabs/Shop Items/Level1/soldier_item_LVL1.tscn"),
	13: preload("res://Prefabs/Shop Items/Level2/soldier_item_LVL2.tscn"),
	14: preload("res://Prefabs/Shop Items/Level3/soldier_item_LVL3.tscn"),
	#Medic
	15: preload("res://Prefabs/Shop Items/Level1/medic_item_LVL1.tscn"),
	16: preload("res://Prefabs/Shop Items/Level2/medic_item_LVL2.tscn"),
	17: preload("res://Prefabs/Shop Items/Level3/medic_item_LVL3.tscn"),
	#Polearm
	18: preload("res://Prefabs/Shop Items/Level1/polearm_item_LVL1.tscn"),
	19: preload("res://Prefabs/Shop Items/Level2/polearm_item_LVL2.tscn"),
	20: preload("res://Prefabs/Shop Items/Level3/polearm_item_LVL3.tscn"),
	#Sniper
	21: preload("res://Prefabs/Shop Items/Level1/sniper_item_LVL1.tscn"),
	22: preload("res://Prefabs/Shop Items/Level2/sniper_item_LVL2.tscn"),
	23: preload("res://Prefabs/Shop Items/Level3/sniper_item_LVL3.tscn")
}

var booster_scenes = {
	0: preload("res://Prefabs/Shop Items/Boosters/booster_medieval.tscn"),
	1: preload("res://Prefabs/Shop Items/Boosters/booster_army.tscn")
}

var base_scenes = {
	0: preload("res://Prefabs/Shop Items/Bases/castle_base.tscn"),
	1: preload("res://Prefabs/Shop Items/Bases/bank_base.tscn")
}
