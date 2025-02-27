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
		#LOSE
		print("YOU LOSE")
	#If this is the enemies headquarters, then we win
	else:
		print("YOU WIN")
