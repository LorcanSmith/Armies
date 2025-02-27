extends Node
#Game manager
var game_manager : Node2D

# used to end combat and return to store
var battle_over : bool = false

# army belonging to the user running the client
var player_army : Array = []

# army belonging to the opponent that has been received from the server
var enemy_army : Array = []

	
func battle_ticker():
	while !battle_over:
		movement_phase()
		combat_phase()

func movement_phase():
	#The grid in a normal layout, used for the enemy units
	var grid_forward = game_manager.GridManager.get_grid()
	#The grid in a revered layout, used for the player units
	var grid_reversed = grid_forward.duplicate()
	grid_reversed.reverse()
	
	#Both the grids, forward and reversed
	var grids : Array = [grid_forward, grid_reversed]
	
	#For both of the grids
	for grid in grids:
		for width in range(grid.size()):
			for tile in range(width):
				#If there is a unit on the tile
				if(grid[width][tile].units_on_tile.size() == 1):
					#Space which the unit will move to
					var unit_space_to_move
					#The unit on the grid
					var unit = grid[width][tile].units_on_tile[0]
					#If its a player unit, move in a forward direction
					if(unit.is_in_group("player")):
						unit_space_to_move = grid_reversed[width][tile - 1] 
						print("I did somethinbg els")
					#If its an enemy unit, move in a backwards direction
					else:
						unit_space_to_move = grid_forward[width][tile - 1] 
						print("I did somethinbg")
					#If the grid in front of the unit is empty, then we can move there
					if(grid[width][unit_space_to_move].is_empty):
						unit.tile_to_move_to = grid[width][unit_space_to_move]
						#Set the current tile to be empty so other units can move here
						unit.get_parent().is_empty = true
						#move the unit
						unit.move()
					#If there is more than one unit on the tile then they can't move as they are brawling
					#elif(tile.units_on_tile.size() > 1):
						#pass

func combat_phase():
#	call skill() for each unit that can use them or calculate brawl damage
#	manage stats of both armies and both bases
	var base_destroyed = true
	if base_destroyed:
		battle_over = true
