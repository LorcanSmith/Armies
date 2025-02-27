extends Node
#Game manager
var game_manager : Node2D

#Keeps track of which phase we are in
var movement_next_phase = true

# used to end combat and return to store
var battle_over : bool = false

# army belonging to the user
var player_army : Array = []
# army belonging to the opponent
var enemy_army : Array = []

	
func battle_ticker():
	#while !battle_over:
	#If movement is next
	if(movement_next_phase):
		movement_phase()
	#If movement is not next, it must be combat
	else:
		combat_phase()
		#combat_phase()

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
	for grid in grids:
		x = 0
		while(x < grid.size()):
			y = 0
		#Loop through the grid
			while(y < grid[x].size()):
				#If there is a unit on the tile
				if(grid[x][y].units_on_tile.size() == 1):
					#Space which the unit will move to
					var unit_space_to_move
					#The unit on the grid
					var unit = grid[x][y].units_on_tile[0]
					#If the unit hasn't already moved this turn
					if(unit.moved == false):
						#If its a player unit, move in a forward direction
						if(unit.is_in_group("player")):
							#Add this unit to the array as its still alive
							player_army.append(unit)
							#Find the spot which we wish to move to
							unit_space_to_move = grid_forward[x+1][y] 
						#If its an enemy unit, move in a backwards direction
						else:
							#Add this unit to the array as its still alive
							enemy_army.append(unit)
							#Find the spot which we wish to move to
							unit_space_to_move = grid_forward[x-1][y] 
						#If the grid in front of the unit is empty, then we can move there
						if(unit_space_to_move.is_empty):
							#Tell the current tile the unit is on that the unit is moving off it
							unit.get_parent().units_on_tile = []
							#Set the current tile to be empty so other units can move here
							unit.get_parent().is_empty = true
							#move the unit
							unit.move(unit_space_to_move)
				#If there is more than one unit on the tile then they can't move as they are brawling
				elif(grid[x][y].units_on_tile.size() > 1):
					print("BRAWL")
				y += 1
			x += 1 
			
func combat_phase():
	#Combat is this turn so set the movement phase to be next turn
	movement_next_phase = true
	#Tell each unit in the enemy army to do their skill
	for unit in enemy_army:
		unit.skill()
	#Tell each unit in the player army to do their skill
	for unit in player_army:
		unit.skill()
		
		
	var base_destroyed = true
	if base_destroyed:
		battle_over = true
