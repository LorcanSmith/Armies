extends Node

#What is the name of this grid
@export var grid_name : String

#Is the generation for the battle or the shop? Will spawn a different tile based on this
@export var is_battle_grid : bool = false

#Width and Height of the grid to be generated
var grid_width : int = 1
var grid_height : int = 1

@export var combat_grid_width : int
@export var width_per_turn = [3,3,4,4]
@export var height_per_turn = [2,3,3,4]

#Tile that is placed at each grid position
var tile : PackedScene

#Array of the generated grid, stored as [[0,0],[0,1]] etc.
var grid : Array = []
#Array of the units on the grid and their IDs. Used for saving the scene
var grid_with_unit_IDs : Array = []

func _ready() -> void:
	#Sets the tile to be the tile used in battle
	if(is_battle_grid):
		tile = preload("res://Prefabs/Grid/battle_tile.tscn")
	#Sets the tile to be the tile used in the army builder
	else:
		tile = preload("res://Prefabs/Grid/builder_tile.tscn")

#Generates a grid
func generate_grid(turn_number : int, in_combat : bool):
	if(width_per_turn.size() > turn_number):
		grid_width = width_per_turn[turn_number - 1]
		grid_height = height_per_turn[turn_number - 1]
	else:
		grid_width = width_per_turn[-1]
		grid_height = height_per_turn[-1]
	if(in_combat):
		grid_width = combat_grid_width
	#Resizes the array to be the size of the width
	grid.resize(grid_width)
	grid_with_unit_IDs.resize(grid_width)
	
	#Loops over the grid width
	for width in range(grid_width):
		#Creates an array at each width position
		grid[width] = Array()
		grid_with_unit_IDs[width] = Array()
		
		#Resizes the new array to be the size of the grid height
		grid[width].resize(grid_height)
		grid_with_unit_IDs[width].resize(grid_height)
		
		#Loops over the grid height
		for height in range(grid_height):
			#Instantiates the tile prefab for each grid row and column
			var new_tile = tile.instantiate()
			#Sets the newly made tile's position to be at the right grid spot
			#Offset the width and height by the size of the tile
			var offset = (new_tile.find_child("Sprite2D").texture.get_width())-4
			new_tile.global_position = Vector2i(width * offset, height * offset)
			#Adds the newly generated tile as a child of this node
			add_child(new_tile)
			#Sets the current grid position to be the newly generated tile
			grid[width][height] = new_tile
			
			if(is_battle_grid):
				find_child("Camera2D").global_position = Vector2(((float(combat_grid_width)/2)*(offset-8)),0)
	
	return true
#Called when you want to save the current unit layout of the grid
func save_current_grid():
	#Loops over the entire grid and the units on the grid
	for width in range(grid_width):
		for height in range(grid_height):
			#If there is a unit on the grid tile
			if(grid[width][height].units_on_tile.size() > 0 and grid[width][height].units_on_tile[0] != null):
				#Gets the unit on the tile for easy access
				var unit = grid[width][height].units_on_tile[0]
				#Save the unit ID and data in the grid to be used later
				grid_with_unit_IDs[width][height] = [unit.unit_ID, unit.damage_boost, unit.health_boost]
			#If the is no unit on the grid tile
			else:
				#Set that grid id to be null. This updates any tiles that previously had a unit on it
				grid_with_unit_IDs[width][height] = null
	#Tells the manager to save the layout of the grid, includes the name and a list
	#of all the unit IDs
	find_parent("grid_manager").save_layout(grid_name, grid_with_unit_IDs)
