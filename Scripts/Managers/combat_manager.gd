extends Node

var battle_over = false

##TODO
#SPAWN ARMIES
#SWITCH BETWEEN SKILL/MOVING

func _ready():
#	Read in both armies and place them on the grid
#	begin with move phase
	battle_ticker()
	
func battle_ticker():
	while !battle_over:
		movement_phase()
		combat_phase()

func movement_phase():
#	calls move() on all units
#	if an enemy unit is 1 space away, don't move
#	opposing units that occupy the same space will brawl
	pass

func combat_phase():
#	call skill() for each unit that can use them or calculate brawl damage
#	manage stats of both armies and both bases
	var base_destroyed = true
	if base_destroyed:
		battle_over = true
