extends Node

@export var max_health = 150
@export var health = 150

func _ready():
	update_label()

#Does damage and heals headquaters
#Positive numbers to hurt, negative numbers to heal
var dead = false
func hurt(amount : int):
	if(!dead):
		health -= amount
		update_label()
		if(health <= 0):
			dead = true
			destroy_headquarters()
		
func update_label():
	$Label.text = str(health) + "/" + str(max_health)

#Called when the headquater runs out of health
func destroy_headquarters():
	queue_free()
