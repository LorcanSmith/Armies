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
	23: preload("res://Prefabs/Units/Level3/sniper_unit_LVL3.tscn"),
	#Mechanic
	24: preload("res://Prefabs/Units/Level1/mechanic_unit_LVL1.tscn"),
	25: preload("res://Prefabs/Units/Level2/mechanic_unit_LVL2.tscn"),
	26: preload("res://Prefabs/Units/Level3/mechanic_unit_LVL3.tscn"),
	#Plague Doctor
	27: preload("res://Prefabs/Units/Level1/plague_doctor_unit_LVL1.tscn"),
	28: preload("res://Prefabs/Units/Level2/plague_doctor_unit_LVL2.tscn"),
	29: preload("res://Prefabs/Units/Level3/plague_doctor_unit_LVL3.tscn"),
	#Werewolf
	30: preload("res://Prefabs/Units/Level1/werewolf_unit_LVL1.tscn"),
	31: preload("res://Prefabs/Units/Level2/werewolf_unit_LVL2.tscn"),
	32: preload("res://Prefabs/Units/Level3/werewolf_unit_LVL3.tscn"),
	#Antitank
	33: preload("res://Prefabs/Units/Level1/antitank_unit_LVL1.tscn"),
	34: preload("res://Prefabs/Units/Level2/antitank_unit_LVL2.tscn"),
	35: preload("res://Prefabs/Units/Level3/antitank_unit_LVL3.tscn"),
	#Orc
	36: preload("res://Prefabs/Units/Level1/orc_unit_LVL1.tscn"),
	37: preload("res://Prefabs/Units/Level2/orc_unit_LVL2.tscn"),
	38: preload("res://Prefabs/Units/Level3/orc_unit_LVL3.tscn"),
	#Chicken
	39: preload("res://Prefabs/Units/Level1/chicken_unit_LVL1.tscn"),
	40: preload("res://Prefabs/Units/Level2/chicken_unit_LVL2.tscn"),
	41: preload("res://Prefabs/Units/Level3/chicken_unit_LVL3.tscn"),
	#Sheep
	42: preload("res://Prefabs/Units/Level1/sheep_unit_LVL1.tscn"),
	43: preload("res://Prefabs/Units/Level2/sheep_unit_LVL2.tscn"),
	44: preload("res://Prefabs/Units/Level3/sheep_unit_LVL3.tscn"),
	#Pig
	45: preload("res://Prefabs/Units/Level1/pig_unit_LVL1.tscn"),
	46: preload("res://Prefabs/Units/Level2/pig_unit_LVL2.tscn"),
	47: preload("res://Prefabs/Units/Level3/pig_unit_LVL3.tscn"),
	#Stegosaurus
	48: preload("res://Prefabs/Units/Level1/stegosaurus_unit_LVL1.tscn"),
	49: preload("res://Prefabs/Units/Level2/stegosaurus_unit_LVL2.tscn"),
	50: preload("res://Prefabs/Units/Level3/stegosaurus_unit_LVL3.tscn"),
	#Diplodocus
	51: preload("res://Prefabs/Units/Level1/diplodocus_unit_LVL1.tscn"),
	52: preload("res://Prefabs/Units/Level2/diplodocus_unit_LVL2.tscn"),
	53: preload("res://Prefabs/Units/Level3/diplodocus_unit_LVL3.tscn"),
	#Bomb bot
	54: preload("res://Prefabs/Units/Level1/bombbot_unit_LVL1.tscn"),
	55: preload("res://Prefabs/Units/Level2/bombbot_unit_LVL2.tscn"),
	56: preload("res://Prefabs/Units/Level3/bombbot_unit_LVL3.tscn"),
	#Velociraptor
	57: preload("res://Prefabs/Units/Level1/velociraptor_unit_LVL1.tscn"),
	58: preload("res://Prefabs/Units/Level2/velociraptor_unit_LVL2.tscn"),
	59: preload("res://Prefabs/Units/Level3/velociraptor_unit_LVL3.tscn"),
   #Trex
	60: preload("res://Prefabs/Units/Level1/trex_unit_LVL1.tscn"),
	61: preload("res://Prefabs/Units/Level2/trex_unit_LVL2.tscn"),
	62: preload("res://Prefabs/Units/Level3/trex_unit_LVL3.tscn"),
	#Ankylosaurus
	63: preload("res://Prefabs/Units/Level1/ankylosaurus_unit_LVL1.tscn"),
	64: preload("res://Prefabs/Units/Level2/ankylosaurus_unit_LVL2.tscn"),
	65: preload("res://Prefabs/Units/Level3/ankylosaurus_unit_LVL3.tscn")
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
	23: preload("res://Prefabs/Shop Items/Level3/sniper_item_LVL3.tscn"),
	#Mechanic
	24: preload("res://Prefabs/Shop Items/Level1/mechanic_item_LVL1.tscn"),
	25: preload("res://Prefabs/Shop Items/Level2/mechanic_item_LVL2.tscn"),
	26: preload("res://Prefabs/Shop Items/Level3/mechanic_item_LVL3.tscn"),
	#Plague Doctor
	27: preload("res://Prefabs/Shop Items/Level1/plague_doctor_item_LVL1.tscn"),
	28: preload("res://Prefabs/Shop Items/Level2/plague_doctor_item_LVL2.tscn"),
	29: preload("res://Prefabs/Shop Items/Level3/plague_doctor_item_LVL3.tscn"),
	#Werewolf
	30: preload("res://Prefabs/Shop Items/Level1/werewolf_item_LVL1.tscn"),
	31: preload("res://Prefabs/Shop Items/Level2/werewolf_item_LVL2.tscn"),
	32: preload("res://Prefabs/Shop Items/Level3/werewolf_item_LVL3.tscn"),
	#Antitank
	33: preload("res://Prefabs/Shop Items/Level1/antitank_item_LVL1.tscn"),
	34: preload("res://Prefabs/Shop Items/Level2/antitank_item_LVL2.tscn"),
	35: preload("res://Prefabs/Shop Items/Level3/antitank_item_LVL3.tscn"),
	#Orc
	36: preload("res://Prefabs/Shop Items/Level1/orc_item_LVL1.tscn"),
	37: preload("res://Prefabs/Shop Items/Level2/orc_item_LVL2.tscn"),
	38: preload("res://Prefabs/Shop Items/Level3/orc_item_LVL3.tscn"),
	#Chicken
	39: preload("res://Prefabs/Shop Items/Level1/chicken_item_LVL1.tscn"),
	40: preload("res://Prefabs/Shop Items/Level2/chicken_item_LVL2.tscn"),
	41: preload("res://Prefabs/Shop Items/Level3/chicken_item_LVL3.tscn"),
	#Sheep
	42: preload("res://Prefabs/Shop Items/Level1/sheep_item_LVL1.tscn"),
	43: preload("res://Prefabs/Shop Items/Level2/sheep_item_LVL2.tscn"),
	44: preload("res://Prefabs/Shop Items/Level3/sheep_item_LVL3.tscn"),
	#Pig
	45: preload("res://Prefabs/Shop Items/Level1/pig_item_LVL1.tscn"),
	46: preload("res://Prefabs/Shop Items/Level2/pig_item_LVL2.tscn"),
	47: preload("res://Prefabs/Shop Items/Level3/pig_item_LVL3.tscn"),
	#Stegosaurus
	48: preload("res://Prefabs/Shop Items/Level1/stegosaurus_item_LVL1.tscn"),
	49: preload("res://Prefabs/Shop Items/Level2/stegosaurus_item_LVL2.tscn"),
	50: preload("res://Prefabs/Shop Items/Level3/stegosaurus_item_LVL3.tscn"),
	#Diplodocus
	51: preload("res://Prefabs/Shop Items/Level1/diplodocus_item_LVL1.tscn"),
	52: preload("res://Prefabs/Shop Items/Level2/diplodocus_item_LVL2.tscn"),
	53: preload("res://Prefabs/Shop Items/Level3/diplodocus_item_LVL3.tscn"),
	#Bomb Bot
	54: preload("res://Prefabs/Shop Items/Level1/bombbot_item_LVL1.tscn"),
	55: preload("res://Prefabs/Shop Items/Level2/bombbot_item_LVL2.tscn"),
	56: preload("res://Prefabs/Shop Items/Level3/bombbot_item_LVL3.tscn"),
	#Velociraptor
	57: preload("res://Prefabs/Shop Items/Level1/velociraptor_item_LVL1.tscn"),
	58: preload("res://Prefabs/Shop Items/Level2/velociraptor_item_LVL2.tscn"),
	59: preload("res://Prefabs/Shop Items/Level3/velociraptor_item_LVL3.tscn"),
  	#Trex
	60: preload("res://Prefabs/Shop Items/Level1/trex_item_LVL1.tscn"),
	61: preload("res://Prefabs/Shop Items/Level2/trex_item_LVL2.tscn"),
	62: preload("res://Prefabs/Shop Items/Level3/trex_item_LVL3.tscn"),
	#Ankylosaurus
	63: preload("res://Prefabs/Shop Items/Level1/ankylosaurus_item_LVL1.tscn"),
	64: preload("res://Prefabs/Shop Items/Level2/ankylosaurus_item_LVL2.tscn"),
	65: preload("res://Prefabs/Shop Items/Level3/ankylosaurus_item_LVL3.tscn")
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
	4: preload("res://Prefabs/Shop Items/Bases/upgraded_army_base.tscn")
	
}
