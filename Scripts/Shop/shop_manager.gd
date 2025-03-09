extends Node

#The Game Manager
var game_manager
var status_bar: StatusBar

@export var free_reroll : bool = true
@export var reroll_cost : int = 2

#Amount of money the player can spend each turn
@export var money : int = 30

func _ready() -> void:
	game_manager = find_parent("game_manager")
	money += game_manager.money_remaining
	game_manager.money_changed(money)
#Called when we want to add or take away money
func change_money(amount : int):
	money -= amount
	game_manager.money_changed(money)
