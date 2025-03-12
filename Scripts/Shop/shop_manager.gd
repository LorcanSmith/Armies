extends Node

#The Game Manager
var game_manager
var status_bar: StatusBar

@export var free_reroll : bool = true
@export var reroll_cost : int = 2

#Amount of money the player can spend each turn
@export var money : int = 30
var same_units = []

func _ready() -> void:
	game_manager = find_parent("game_manager")
	money += game_manager.money_remaining
	game_manager.money_changed(money)
#Called when we want to add or take away money
func change_money(amount : int):
	money -= amount
	game_manager.money_changed(money)


func _on_battle_button_pressed() -> void:
	game_manager.swap_scenes()

func show_potential_upgrades(show : bool, item_who_called : Node2D):
		if(show):
			var tiles = find_child("grid_manager").find_child("grid_generator (army)").get_children()
			var x = 0
			#Loops over all tiles
			while (x < (tiles.size())):
				var y = 0
				var children = tiles[x].get_children()
				while (y < (children.size())):
					#If there is a item on the tile
					if(children[y].is_in_group("item")):
						#if that item is the same as the current item and it can be upgraded
						if(children[y].unit_ID == item_who_called.unit_ID and children[y].can_be_upgraded and children[y] != item_who_called):
							#Add it to the same units array
							same_units.append(children[y])
					y+=1
				x+=1
		for unit in same_units:
			if(unit):
				unit.upgrade_arrow.visible = show
		if(!show):
			same_units = []
		
