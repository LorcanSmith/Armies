extends Node

@export var health = 150

#Does damage and heals headquaters
#Positive numbers to hurt, negative numbers to heal
func hurt(amount : int):
	health -= amount
	if(health <= 0):
		destroy_headquarters()

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
