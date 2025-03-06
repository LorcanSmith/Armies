extends Node

#The Game Manager
var game_manager
var status_bar: StatusBar

@export var free_reroll : bool = true
@export var reroll_cost : int = 2

signal money_changed

#Amount of money the player can spend each turn
@export var money = 30

func _ready() -> void:
	print("Money: $" + str(money))
	emit_signal("money_changed", money)
  
#Called when we want to add or take away money
func change_money(amount : int):
	money -= amount
	print("Money: $" + str(money))
	emit_signal("money_changed", money)
