extends Node2D

#Unit ID, refer to UNIT ID document
#Items that aren't units do not need an ID
@export var unit_ID : int = -1

#The shop manager keeps track of player money
var shop_manager : Node2D

#How much it costs to buy the item
@export var buy_cost : int = 0
#How much money you get from selling the item
@export var sell_cost : int = 0
#Keeps track if the player has bought the unit yet. Stops the player from selling
#items that haven't been bought yet, as well as making sure the player pays for items
var bought : bool = false

#Set when the player is placing the object. When this item is hovering over
#a tile, the tile is set below. Then when the player "places" the item, we use
#this variable to work out which node to put the item on. Also used for snapping
#the sprite to the grid
var tile_currently_over : Node2D = null

#Used to keep track of if the player is holding the item over the sell area
#If they let go of the item whilst this is set to true, the item will sell
var item_on_sell_location : bool = false

#The child sprite which is the visuals for the item
var sprite : Sprite2D

#Is the player currently hovering over the item, used to detect if they click on this item
var mouse_over_item : bool = false
#Should the item follow the mouse
var follow_mouse : bool = false

func _ready() -> void:
	sprite = find_child("Sprite2D")
	shop_manager = find_parent("shop_manager")
	
#Called when the mouse is hovering over
func _on_area_2d__mouse_collision_mouse_entered() -> void:
	mouse_over_item = true
#Called when the mouse stops hovering over
func _on_area_2d__mouse_collision_mouse_exited() -> void:
	mouse_over_item = false
	
#Checks to see if the mouse is clicked. This is so we can check to see if a user
#has clicked on an item.
func _input(event):
	if event is InputEventMouseButton:
		#Checks to see if something has happened with the left mouse button
		if event.button_index == MOUSE_BUTTON_LEFT:
			#Checks to see if a pressed event happened whilst the mouse was over the item 
			if(event.pressed and mouse_over_item):
				#Follow the mouse
				follow_mouse = true
				#If the unit is on a tile, set the tile to be empty when the unit is picked up
				if(self.get_parent().is_in_group("tile")):
					self.get_parent().is_empty = true
					#Tell the tile that it no longer needs to keep track of the current unit
					self.get_parent().units_on_tile[0] = null
			#If the mouse button is lifted up the item should no longer follow the mouse
			elif(!event.pressed):
				follow_mouse = false
				#The item should attempt to be placed when the user lets go of it
				attempt_to_place()
				
func _process(delta: float) -> void:
	#If the player has clicked on an item in the shop
	if(follow_mouse):
		#Follow the mouse
		self.global_position = get_global_mouse_position()
	else:
		self.position = Vector2(0,0)
	#If the item is currently over a tile that is empty
	if(tile_currently_over != null and tile_currently_over.is_empty):
		#Snap to the tile location
		sprite.global_position = tile_currently_over.global_position
	#If there is no valid tile to snap to
	elif(tile_currently_over == null):
		#Reset the sprite postion back to the parents position.
		#The parent is either following the mouse or set to the shop item location
		sprite.position = Vector2(0,0)

#Called when the player attempts to place the item on a tile
func attempt_to_place():
	##NOTE - Will need to be updated when boosts are added as they won't be placed on a tile
	
	#The player is trying to sell the item and the item has already been bought
	if(item_on_sell_location and bought):
		sell_item()	
	
	#If the item has been bought already
	if(bought):			
		#If there is an available tile underneath the unit, then we can place it
		if(tile_currently_over != null and tile_currently_over.is_empty):
			place_item()
		#Not enough money or not a valid tile will reset the node back to the shop item locaiton
		else:
			#Resets position back to parent which is the item shop location or 
			self.position = Vector2(0,0)
	else:
		if(shop_manager.money >= buy_cost):
			#If there is an available tile underneath the unit, then we can place it
			if(tile_currently_over != null and tile_currently_over.is_empty):
				#Spend the money required to buy the item
				shop_manager.change_money(buy_cost)
				#Change the item to be bought
				bought = true
				place_item()
			#Not enough money or not a valid tile will reset the node back to the shop item locaiton
			else:
				#Resets position back to parent which is the item shop location or 
				self.position = Vector2(0,0)
#Called when an attempt_to_place is sucessful
func place_item():
	#Tells the tile that the unit is placed on to no longer be empty
	#and tells the tile what the unit is
	tile_currently_over.unit_placed_on(self)
	#Set the units' parent to be the tile that it is placed on
	self.reparent(tile_currently_over)
	
##	DEBUG
	if(DebuggerScript.place_enemy):
		self.remove_from_group("player")
		self.add_to_group("enemy")
	
#Called when the player sells the item
func sell_item():
	#Gives the player money for selling an item
	shop_manager.change_money(-sell_cost)
	#Deltes the item
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	#If the area is a tile and the item is picked up, following the mouse
	if(area.is_in_group("tile") and follow_mouse):
		#Set the tile which we are currently over. This is so we can snap the 
		#Sprite2D to the tiles' location
		tile_currently_over = area.get_parent()
	#The player is holding the item over the sell area location
	elif(area.is_in_group("sell_location")):
		item_on_sell_location = true
func _on_area_2d_area_exited(area: Area2D) -> void:
	#If the area we just left is the current tile the sprite is snapping to
	if(area.get_parent() == tile_currently_over):
		#We are no longer over the tile so unset it
		tile_currently_over = null
		#Reset the sprite position back to the parent node which is following
		#the mouse
		sprite.position = Vector2(0,0)
	#The player has stopped holding the item over the sell area location
	elif(area.is_in_group("sell_location")):
		item_on_sell_location = false
