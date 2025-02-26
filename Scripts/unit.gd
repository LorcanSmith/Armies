extends Node

#Keeps track of if the unit is on the same tile as an enemy
#and engaged in hand-to-hand combat
var engaged = false
#Does the unit move to defend empty columns
@export var defender : bool

#Damage unit does to other units when
#engaged in hand-to-hand combat (on the same tile as enemy)
@export var damage : int
@export var health : int

#The amount of damage/heals the unit's skill does
@export var skill_damage : int
@export var skill_heal : int

#Moves the unit in a desired direction and distance
func move(direction : Vector2i, distance : Vector2i):
##	TODO
	pass

func skill():
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
