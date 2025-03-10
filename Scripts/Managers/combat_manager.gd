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

#determines whether the ticks are automatic or called manually
@export var ticker_paused : bool = false

#determines the length between ticks while the ticker is unpaused
@export var tick_delay : float = 0.3

var player_headquarter : Node2D
var enemy_headquarter : Node2D


func _ready() -> void:
	game_manager = find_parent("game_manager")
	player_headquarter = self.find_child("player_headquarter")
	enemy_headquarter = self.find_child("enemy_headquarter")
	auto_tick()

func setup_headquarters():
	#Gets the current grid so we can find out its size
	var grid = game_manager.GridManager.get_grid()
	#Gets the center of the grid in the y axis
	var grid_height_center = (grid[0][-1].global_position.y)/2
	#Gets the tile which is the furthest to the right
	var grid_width = grid[-1]
	#Offsets our headquarters by its sprite size
	var offset = (find_child("Sprite2D").texture.get_width())+60
	#Sets the player headquarter to be to the left of the map
	player_headquarter.global_position = Vector2(-offset, grid_height_center)
	#Get enemy child Sprite 2D and flip horizontally
	var enemy_base = enemy_headquarter.get_node("Sprite2D")  
	enemy_base.flip_h = true  
	#Sets the player headquarter to be to the right of the map
	enemy_headquarter.global_position = Vector2(grid_width[0].global_position.x + offset, grid_height_center)

# called from ready() or from game_manager, automatically cycles through battle_ticker()
func auto_tick():
##		causes the function to pause, allows an opening for game_manager to pause if necessary
	if(!ticker_paused):
		await get_tree().create_timer(tick_delay).timeout
		battle_ticker()
	
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

var units_moved = 0
var units_to_move = []
func movement_phase():
	units_to_move = []
	units_moved = 0
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
	
	while(grid_number < grids.size()):
		x = 0
		while(x < grids[grid_number].size()):
			y = 0
		#Loop through the grid
			while(y < grids[grid_number][x].size()):
				#Space which the unit will move to
				var unit_space_to_move
				if(grids[grid_number][x][y].units_on_tile.size() == 1):
					#The unit on the grid
					var unit = grids[grid_number][x][y].units_on_tile[0]
					#If its a player unit, move in a forward direction
					if(grids[grid_number] == grid_reversed and unit.is_in_group("player")):
						#If the unit hasn't already moved this turn
						if(unit.moved == false):
							units_to_move.append(unit)
							unit.moved = true
						
						#Add this unit to the array as its still alive
						if(!player_army.has(unit)):
							player_army.append(unit) 
					#If its an enemy unit, move in a backwards direction
					elif(grids[grid_number] == grid_forward and unit.is_in_group("enemy")):
						#If the unit hasn't already moved this turn
						if(unit.moved == false):
							units_to_move.append(unit)
							unit.moved = true
						#Add this unit to the array as its still alive
						if(!enemy_army.has(unit)):
							enemy_army.append(unit)
				#If there are two units then they are brawling and shouldnt move
				elif(grids[grid_number][x][y].units_on_tile.size() == 2):
					#Get each unit on the tile
					for unit in grids[grid_number][x][y].units_on_tile:
						if(unit.is_in_group("player")):
							player_army.append(unit)
						else:
							enemy_army.append(unit)
				y += 1
			x += 1
		grid_number += 1
	find_units_movement_tile()

#Finds a tile for each unit, looped from the unit once it has found a tile
var unit_to_find_tile = 0	
func find_units_movement_tile():
	if(units_to_move.size() > 0):
		units_to_move[unit_to_find_tile].find_movement_tile()
	else:
		auto_tick()
	
func move_units():
	var u = 0
	while u < units_to_move.size():
		units_to_move[u].move()
		u += 1
	auto_tick()
func combat_phase():
	#If there are still units on the board
	if(player_army.size() > 0 or enemy_army.size() > 0):
		#Used to check if any units remain that can do damage
		var damage_unit_alive = false
		#Combat is this turn so set the movement phase to be next turn
		movement_next_phase = true
		#Tell each unit in the enemy army to do their skill
		var unit = 0
		while unit in range(player_army.size()):
			player_army[unit].skill()
			#Checks to see if the unit can do damage
			if(player_army[unit].skill_damage > 0):
				damage_unit_alive = true
			unit += 1
		#Tell each unit in the player army to do their skill
		unit = 0
		while unit in range(enemy_army.size()):
			enemy_army[unit].skill()
			if(enemy_army[unit].skill_damage > 0):
				damage_unit_alive = true
			unit += 1
		#If a unit who can damage the base is still alive continue game
		if(damage_unit_alive):
			#Tell the skill_holder that skills have been spawned and we're waiting for them to be finished
			find_child("skill_holder").waiting_for_skills = true
		#If no units that can do damage to bases are alive, then end the combat
		else:
			end_combat()
	#No units exist, you win
	else:
		end_combat()
func end_combat():
	game_manager.won_battle(true)
	battle_over = true
	auto_tick()

#Called by the skill_holder child when no skills remain, meaning we can proceed with combat
func no_skills_left():
	#Tells the units to take damage
	var unit = 0
	while unit in range(player_army.size()):
		player_army[unit].apply_damage()
		unit += 1
	unit = 0
	while unit in range(enemy_army.size()):
		enemy_army[unit].apply_damage()
		unit += 1
	
	#Used for checking to see if anyone has won
	var enemy_headquarter_alive : bool = false
	var player_headquarter_alive : bool = false
	#Sees if both headquarters are alive
	if(find_child("player_headquarter")):
		player_headquarter_alive = true
	if(find_child("enemy_headquarter")):
		enemy_headquarter_alive = true
	#Based on which headquarters are alive we can work out who won
	#Player wins
	if(player_headquarter_alive and !enemy_headquarter_alive):
		game_manager.won_battle(true)
		battle_over = true
	#Enemy wins
	elif(!player_headquarter_alive and enemy_headquarter_alive):
		game_manager.won_battle(false)
		battle_over = true
	#Its a draw, so counts as a win
	elif(!player_headquarter_alive and !enemy_headquarter_alive):
		game_manager.won_battle(true)
		battle_over = true
	auto_tick()


func _on_play_button_toggled(toggled_on):
	tick_delay = 0.3
	if ticker_paused:
		ticker_paused = false
		auto_tick()

func _on_pause_button_toggled(toggled_on):
	ticker_paused = true

func _on_forward_toggled(toggled_on):
	tick_delay = 0.1
	if ticker_paused:
		ticker_paused = false
		auto_tick()
