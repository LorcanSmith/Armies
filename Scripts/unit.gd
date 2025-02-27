extends Node

#Unit ID
@export var unit_ID : int = -1

#Keeps track of if the unit is on the same tile as an enemy (brawling)
var brawling = false
#Does the unit move to defend empty columns
@export var defender : bool

#Damage done when brawling
@export var brawl_damage : int
#Units health
@export var health : int

#The amount of damage/heals the unit's skill does
@export var skill_damage : int
@export var skill_heal : int

#The location where the skill will spawn*
var skill_location = []

#Keep track of if the unit has moved this turn
var moved = false

#Moves the unit in a desired direction and distance
func move(new_tile):
	#The unit has moved this turn
	moved = true
	#Set the parent to be the new tile
	reparent(new_tile)
	#Tell the new tile that this unit is now on it
	new_tile.unit_placed_on(self)
	#Set the units position to the new tile (units' parent)
	self.position = Vector2(0,0)
	print("MOVED")

func skill():
	moved = false
	print("SKILL")
##	TODO
##	Instantiate the skill
	pass

#Does damage and heals unit
#Positive numbers to hurt, negative numbers to heal
func hurt(amount : int):
	health -= amount
	if(health <= 0):
		destroy_unit()
#Called when the unit is destroyed
func destroy_unit():
	queue_free()
