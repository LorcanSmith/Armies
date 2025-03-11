extends Node

@export var max_health = 150
var health = 150

var damage_to_do : int

func _ready():
	update_label()

#Does damage and heals headquaters
#Positive numbers to hurt, negative numbers to heal
var dead = false
func hurt(amount : int):
	if(!dead):
		damage_to_do += amount

func apply_damage():
	if(!dead):
		health -= damage_to_do
		update_label()
		if(health <= 0):
			dead = true
			destroy_headquarters()
		damage_to_do = 0
		
func update_label():
	$Label.text = str(health) + "/" + str(max_health)

#Called when the headquater runs out of health
func destroy_headquarters():
	queue_free()
