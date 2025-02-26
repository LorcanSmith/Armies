extends Node2D

#Unit ID, refer to UNIT ID document
#Items that aren't units do not need an ID
@export var unit : int = -1

#How much it costs to buy the item
@export var buy_cost : int = 0
#How much money you get from selling the item
@export var sell_cost : int = 0

#Is the player currently hovering over the item, used to detect if they click on this item
var mouse_over_item : bool = false
#Should the item follow the mouse
var follow_mouse : bool = false
#Called when the mouse is hovering over
func _on_area_2d_mouse_entered() -> void:
	mouse_over_item = true
#Called when the mouse stops hovering over
func _on_area_2d_mouse_exited() -> void:
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
			#If the mouse button is lifted up the item should no longer follow the mouse
			elif(!event.pressed):
				follow_mouse = false
				#The item should attempt to be purchased when the user lets go of it
				attempt_to_buy()
				
func _process(delta: float) -> void:
	if(follow_mouse):
		self.global_position = get_global_mouse_position()
		
#Called when the player attempts to buy the item
func attempt_to_buy():
	##TODO
	#Check if the item is over a free grid spot/a unit of the same type and if
	#the player has enough money
	#Resets position back to parent
	self.position = Vector2(0,0)
#Called when the player sells the item
func sell_item():
	pass
