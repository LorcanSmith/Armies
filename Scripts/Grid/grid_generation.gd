extends Node

#Is the generation for the battle or the shop? Will spawn a different tile based on this
@export var is_battle_grid : bool = false

#Width and Height of the grid to be generated
@export var grid_width : int = 1
@export var grid_height : int = 1

#Tile that is placed at each grid position
var tile : PackedScene

#Array of the generated grid, stored as [[0,0],[0,1]] etc.
var grid : Array = []

func _ready() -> void:
	#Sets the tile to be the tile used in battle
	if(is_battle_grid):
		tile = preload("res://Prefabs/World/battle_tile.tscn")
	#Sets the tile to be the tile used in the army builder
	else:
		tile = preload("res://Prefabs/World/builder_tile.tscn")
	#Generates a grid at run time
	generate_grid()

#Generates a grid
func generate_grid():
	#Resizes the array to be the size of the width
	grid.resize(grid_width)
	#Loops over the grid width
	for width in range(grid_width):
		#Creates an array at each width position
		grid[width] = Array()
		#Resizes the new array to be the size of the grid height
		grid[width].resize(grid_height)
		#Loops over the grid height
		for height in range(grid_height):
			#Instantiates the tile prefab for each grid row and column
			var new_tile = tile.instantiate()
			#Sets the newly made tile's position to be at the right grid spot
			#Offset the width and height by the size of the tile
			var offset = new_tile.find_child("Sprite2D").texture.get_width()
			new_tile.global_position = Vector2i(width * offset, height * offset)
			#Adds the newly generated tile as a child of this node
			add_child(new_tile)
			#Sets the current grid position to be the newly generated tile
			grid[width][height] = new_tile
