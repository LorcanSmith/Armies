extends Node
#Game manager
var game_manager : Node2D

#Keeps track of which phase we are in
var movement_next_phase = true

# used to end combat and return to store
var battle_over : bool = false
#If the enemy base gets destroyed, this gets set to true
var player_won : bool = false

#army belonging to the user
var player_army : Array = []
#army belonging to the opponent
var enemy_army : Array = []

var player_headquarter : Node2D
var enemy_headquarter : Node2D

func _ready() -> void:
	game_manager = find_parent("game_manager")
	player_headquarter = self.find_child("player_headquarter")
	enemy_headquarter = self.find_child("enemy_headquarter")
func setup_headquarters():
	#Gets the current grid so we can find out its size
	var grid = game_manager.GridManager.get_grid()
	#Gets the center of the grid in the y axis
	var grid_height_center = (grid[0][-1].global_position.y)/2
	#Gets the tile which is the furthest to the right
	var grid_width = grid[-1]
	#Offsets our headquarters by its sprite size
	var offset = find_child("Sprite2D").texture.get_width()
	#Sets the player headquarter to be to the left of the map
	player_headquarter.global_position = Vector2(-offset, grid_height_center)
	#Sets the player headquarter to be to the right of the map
	enemy_headquarter.global_position = Vector2(grid_width[0].global_position.x + offset, grid_height_center)


func battle_ticker():
	#If the battle isn't over, keep the units fighting
	if(!battle_over):
		#If movement is next
		if(movement_next_phase):
			movement_phase()
		#If movement is not next, it must be combat
		else:
			combat_phase()
			#combat_phase()
	#If the battle is over then go back to the shop
	else:
		game_manager.swap_scenes()
func movement_phase():
	#Makes sure we don't do two sets of movement
	movement_next_phase = false
	#Clears the player and enemy army
	player_army = []
	enemy_army = []
	
	#The grid in a normal layout, used for the enemy units
	var grid_forward = game_manager.GridManager.get_grid()
	#The grid in a revered layout, used for the player units
	var grid_reversed = grid_forward.duplicate()
	grid_reversed.reverse()
	
	#Both the grids, forward and reversed
	var grids : Array = [grid_forward, grid_reversed]
	#Used to loop over the entire grid
	var x = 0
	var y = 0
	var grid_number = 0
	
	var units_to_move = []
	while(grid_number < grids.size()):
		x = 0
		while(x < grids[grid_number].size()):
			y = 0
		#Loop through the grid
			while(y < grids[grid_number][x].size()):
				#If there is a unit on the tile
				if(grids[grid_number][x][y].units_on_tile.size() == 1):
					#Space which the unit will move to
					var unit_space_to_move
					#The unit on the grid
					var unit = grids[grid_number][x][y].units_on_tile[0]
					#If the unit hasn't already moved this turn
					if(unit.moved == false):
						#If its a player unit, move in a forward direction
						if(grids[grid_number] == grid_reversed and unit.is_in_group("player")):
							#Add this unit to the array as its still alive
							player_army.append(unit)
							#Find the spot which we wish to move to
							unit_space_to_move = grid_reversed[x-1][y] 
						#If its an enemy unit, move in a backwards direction
						elif(grids[grid_number] == grid_forward and unit.is_in_group("enemy")):
							#Add this unit to the array as its still alive
							enemy_army.append(unit)
							#Find the spot which we wish to move to
							unit_space_to_move = grid_forward[x-1][y] 
						#If the grid in front of the unit is empty, then we can move there
						if(unit_space_to_move and unit_space_to_move.is_empty):
							#Tell the current tile the unit is on that the unit is moving off it
							unit.get_parent().units_on_tile = []
							#Set the current tile to be empty so other units can move here
							unit.get_parent().is_empty = true
							#move the unit
							unit.tile_to_move_to = unit_space_to_move
							units_to_move.append(unit)
				#If there are two units on the tile then they can't move as they are brawling
				elif(grids[grid_number][x][y].units_on_tile.size() == 2):
					for unit in range(grids[grid_number][x][y].units_on_tile):
						grids[grid_number][x][y].units_on_tile[unit].brawl()
				y += 1
			x += 1 
		grid_number += 1
	for unit in range(units_to_move):
		units_to_move[unit].move()
func combat_phase():
	#Combat is this turn so set the movement phase to be next turn
	movement_next_phase = true
	#Tell each unit in the enemy army to do their skill
	for unit in enemy_army:
		unit.skill()
	#Tell each unit in the player army to do their skill
	for unit in player_army:
		unit.skill()
		
#Called by a headquarter when it is destroyed
func headquarter_destroyed(enemy_base_destroyed : bool):
	#If it was the enemy base that got destroyed then the player wins
	player_won = enemy_base_destroyed
	#The battle is over
	battle_over = true
