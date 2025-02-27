extends Node

#The Game Manager
var game_manager

#Amount of money the player can spend each turn
@export var money = 30

func _ready() -> void:
	print("Money: $" + str(money))

#Called when we want to add or take away money
func change_money(amount : int):
	money -= amount
	print("Money: $" + str(money))
