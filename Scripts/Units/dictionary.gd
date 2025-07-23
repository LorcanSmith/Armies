extends Node


# Dictionary to store unit IDs and their corresponding scene paths
var unit_scenes = {
	#KNIGHT
	0: preload("res://Prefabs/Units/Level1/knight_unit_LVL1.tscn"),
	#ARCHER
	1: preload("res://Prefabs/Units/Level1/archer_unit_LVL1.tscn"),
	#Catapult
	2: preload("res://Prefabs/Units/Level1/catapult_unit_LVL1.tscn"),
	#Tank
	3: preload("res://Prefabs/Units/Level1/tank_unit_LVL1.tscn"),
	#Soldier
	4: preload("res://Prefabs/Units/Level1/soldier_unit_LVL1.tscn"),
	#Medic
	5: preload("res://Prefabs/Units/Level1/medic_unit_LVL1.tscn"),
	#Polearm
	6: preload("res://Prefabs/Units/Level1/polearm_unit_LVL1.tscn"),
	#Sniper
	7: preload("res://Prefabs/Units/Level1/sniper_unit_LVL1.tscn"),
	#Mechanic
	8: preload("res://Prefabs/Units/Level1/mechanic_unit_LVL1.tscn"),
	#Plague Doctor
	9: preload("res://Prefabs/Units/Level1/plague_doctor_unit_LVL1.tscn"),
	#Werewolf
	10: preload("res://Prefabs/Units/Level1/werewolf_unit_LVL1.tscn"),
	#Antitank
	11: preload("res://Prefabs/Units/Level1/antitank_unit_LVL1.tscn"),
	#Orc
	12: preload("res://Prefabs/Units/Level1/orc_unit_LVL1.tscn"),
	#Chicken
	13: preload("res://Prefabs/Units/Level1/chicken_unit_LVL1.tscn"),
	#Sheep
	14: preload("res://Prefabs/Units/Level1/sheep_unit_LVL1.tscn"),
	#Pig
	15: preload("res://Prefabs/Units/Level1/pig_unit_LVL1.tscn"),
	#Stegosaurus
	16: preload("res://Prefabs/Units/Level1/stegosaurus_unit_LVL1.tscn"),
	#Diplodocus
	17: preload("res://Prefabs/Units/Level1/diplodocus_unit_LVL1.tscn"),
	#Bomb bot
	18: preload("res://Prefabs/Units/Level1/bombbot_unit_LVL1.tscn"),
	#Velociraptor
	19: preload("res://Prefabs/Units/Level1/velociraptor_unit_LVL1.tscn"),
	#Trex
	20: preload("res://Prefabs/Units/Level1/trex_unit_LVL1.tscn"),
	#Ankylosaurus
	21: preload("res://Prefabs/Units/Level1/ankylosaurus_unit_LVL1.tscn"),
	#Dog
	22: preload("res://Prefabs/Units/Level1/dog_unit.tscn"),
	#Wizard
	23: preload("res://Prefabs/Units/Level1/wizard_unit.tscn")
}
var item_scenes = {
	#KNIGHT
	0: preload("res://Prefabs/Shop Items/Level1/knight_item_LVL1.tscn"),
	#ARCHER
	1: preload("res://Prefabs/Shop Items/Level1/archer_item_LVL1.tscn"),
	#Catapult
	2: preload("res://Prefabs/Shop Items/Level1/catapult_item_LVL1.tscn"),
	#Tank
	3: preload("res://Prefabs/Shop Items/Level1/tank_item_LVL1.tscn"),
	#Soldier
	4: preload("res://Prefabs/Shop Items/Level1/soldier_item_LVL1.tscn"),
	#Medic
	5: preload("res://Prefabs/Shop Items/Level1/medic_item_LVL1.tscn"),
	#Polearm
	6: preload("res://Prefabs/Shop Items/Level1/polearm_item_LVL1.tscn"),
	#Sniper
	7: preload("res://Prefabs/Shop Items/Level1/sniper_item_LVL1.tscn"),
	#Mechanic
	8: preload("res://Prefabs/Shop Items/Level1/mechanic_item_LVL1.tscn"),
	#Plague Doctor
	9: preload("res://Prefabs/Shop Items/Level1/plague_doctor_item_LVL1.tscn"),
	#Werewolf
	10: preload("res://Prefabs/Shop Items/Level1/werewolf_item_LVL1.tscn"),
	#Antitank
	11: preload("res://Prefabs/Shop Items/Level1/antitank_item_LVL1.tscn"),
	#Orc
	12: preload("res://Prefabs/Shop Items/Level1/orc_item_LVL1.tscn"),
	#Chicken
	13: preload("res://Prefabs/Shop Items/Level1/chicken_item_LVL1.tscn"),
	#Sheep
	14: preload("res://Prefabs/Shop Items/Level1/sheep_item_LVL1.tscn"),
	#Pig
	15: preload("res://Prefabs/Shop Items/Level1/pig_item_LVL1.tscn"),
	#Stegosaurus
	16: preload("res://Prefabs/Shop Items/Level1/stegosaurus_item_LVL1.tscn"),
	#Diplodocus
	17: preload("res://Prefabs/Shop Items/Level1/diplodocus_item_LVL1.tscn"),
	#Bomb Bot
	18: preload("res://Prefabs/Shop Items/Level1/bombbot_item_LVL1.tscn"),
	#Velociraptor
	19: preload("res://Prefabs/Shop Items/Level1/velociraptor_item_LVL1.tscn"),
  	#Trex
	20: preload("res://Prefabs/Shop Items/Level1/trex_item_LVL1.tscn"),
	#Ankylosaurus
	21: preload("res://Prefabs/Shop Items/Level1/ankylosaurus_item_LVL1.tscn"),
	#Dog
	22: preload("res://Prefabs/Shop Items/Level1/dog_item.tscn"),
	#Wizard
	23: preload("res://Prefabs/Shop Items/Level1/wizard_item.tscn")
}

var booster_scenes = {
	0: preload("res://Prefabs/Shop Items/Boosters/booster_medieval.tscn"),
	1: preload("res://Prefabs/Shop Items/Boosters/booster_army.tscn"),
	2: preload("res://Prefabs/Shop Items/Boosters/booster_farm.tscn"),
	3: preload("res://Prefabs/Shop Items/Boosters/booster_dinosaur.tscn")
}

var base_scenes = {
	0: preload("res://Prefabs/Shop Items/Bases/castle_base.tscn"),
	1: preload("res://Prefabs/Shop Items/Bases/bank_base.tscn"),
	2: preload("res://Prefabs/Shop Items/Bases/army_base.tscn"),
	3: preload("res://Prefabs/Shop Items/Bases/hospital_base.tscn"),
	4: preload("res://Prefabs/Shop Items/Bases/barn_base.tscn")
}
