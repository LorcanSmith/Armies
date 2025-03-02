extends Node

@export var max_health = 150
@export var health = 150

func _ready():
	update_label()

#Does damage and heals headquaters
#Positive numbers to hurt, negative numbers to heal
func hurt(amount : int):
	health -= amount
	update_label()
	if(health <= 0):
		destroy_headquarters()
		
func update_label():
	$Label.text = str(health) + "/" + str(max_health)

#Called when the headquater runs out of head	
func destroy_headquarters():
	#If this is the players headquaters, then we lose
	if(self.is_in_group("player")):
		#Tell the combat manager that the player's headquarter has been destroyed
		get_parent().headquarter_destroyed(false)
		print("YOU LOSE")
	#If this is the enemies headquarters, then we win
	else:
		#Tell the combat manager that the enemy's headquarter has been destroyed
		get_parent().headquarter_destroyed(true)
		print("YOU WIN")
	queue_free()
