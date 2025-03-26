extends Node2D

#Unit dictionary, used to spawn in upgraded units
var dictionary = preload("res://Scripts/Units/dictionary.gd")
#Unit ID, refer to UNIT ID document
#Items that aren't units do not need an ID
var unit_ID : int = -1
#damage and health gained from buffs
var damage_boost : int
var health_boost : int
@export var description : String
var tooltip : Node2D
@export var show_tooltip_time : float = 1.4
var current_time_till_tooltip : float
@export_group("Item is a unit")
@export var unit_name : String
#Can this item be upgraded further?
@export var can_be_upgraded : bool = true
#Keeps track of if the unit is over a potential upgrade
var unit_currently_over_can_upgrade : bool = false
#The shop manager keeps track of player money
var shop_manager : Node2D
#How much it costs to buy the item
@export var buy_cost : int = 0
#How much money you get from selling the item
@export var sell_cost : int = 0
#Keeps track if the player has bought the unit yet. Stops the player from selling
#items that haven't been bought yet, as well as making sure the player pays for items
var bought : bool = false

var upgrade_arrow : Node2D

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
var level_label : Label
var cost_label : Label

#Is the player currently hovering over the item, used to detect if they click on this item
var mouse_over_item : bool = false
#Should the item follow the mouse
var follow_mouse : bool = false
var mouse_pressed : bool = false

#item scale
var item_hovered_scale = 1.2
var item_clicked_scale = 1.4

var skill_tiles : Node2D
var play_skill_popout = false

@export_group("Item buffs")
##Is this item a boost item
@export var can_buff : bool
@export var damage_buff : int
@export var health_buff : int
#locations where buffs happen
var buff_locations : Array = []
#Visual that spawns to show a buff being done
var damage_buff_visual = preload("res://Prefabs/Effects/Buffs/buff_damage.tscn")
var health_buff_visual = preload("res://Prefabs/Effects/Buffs/buff_health.tscn")
var buffs_work_against : Array = []
@export_subgroup("Buffs work for")
@export var Medieval : bool
@export var Army : bool
@export var Vehicle : bool
@export var Human : bool
@export var Soldier : bool
@export var Animal : bool

func _ready() -> void:
	buff_locations = find_child("buffs").get_children()
	upgrade_arrow = find_child("upgrade_arrow")
	skill_tiles = find_child("skill_tiles")
	tooltip = find_child("Tooltip")
	sprite = find_child("Sprite2D")
	shop_manager = find_parent("shop_manager")
	level_label = find_child("Level")
	cost_label = find_child("Cost")
	set_labels()
	set_unit_buff_types()

#Auto assigns the Level label
func set_labels():
	var level_chevron_parent = find_child("level_chevrons")
	var normalised_id = unit_ID + 1
	if(unit_ID % 3 == 0):
		level_chevron_parent.get_child(0).visible = true
	elif(unit_ID % 3 == 1):
		level_chevron_parent.get_child(0).visible = true
		level_chevron_parent.get_child(1).visible = true
	elif(unit_ID % 3 == 2):
		level_chevron_parent.get_child(0).visible = true
		level_chevron_parent.get_child(1).visible = true
		level_chevron_parent.get_child(2).visible = true
	if(unit_ID != -1):
		update_label_text()
	#Set tooltip
	tooltip.update_tooltip()
func update_label_text():
	var attack_label : Label = find_child("Attack")
	var defense_label : Label = find_child("Defense")
	var dictionary_instance = dictionary.new()
	cost_label = find_child("Cost")
	var unit = dictionary_instance.unit_scenes[unit_ID].instantiate()
	attack_label.text = str(unit.skill_damage + damage_boost)
	defense_label.text = str(unit.max_health + health_boost)
	cost_label.text = str(buy_cost)
	
#Called when the mouse is hovering over
func _on_area_2d__mouse_collision_mouse_entered() -> void:
	if(!mouse_pressed):
		mouse_over_item = true
		shop_manager.show_potential_upgrades(true,self)
		sprite.scale = Vector2(item_hovered_scale,item_hovered_scale)
#Called when the mouse stops hovering over
func _on_area_2d__mouse_collision_mouse_exited() -> void:
	if(!mouse_pressed):
		mouse_over_item = false
		shop_manager.show_potential_upgrades(false,self)
		sprite.scale = Vector2(1,1)
	
#Checks to see if the mouse is clicked. This is so we can check to see if a user
#has clicked on an item.
func _input(event):
	if event is InputEventMouseButton:
		#Checks to see if something has happened with the left mouse button
		if event.button_index == MOUSE_BUTTON_LEFT:
			#Checks to see if a pressed event happened whilst the mouse was over the item 
			if(event.pressed):
				mouse_pressed = true
				if(mouse_over_item):
					#Follow the mouse
					follow_mouse = true
					sprite.position = Vector2(0,0)
					if(get_parent().is_in_group("tile")):
						tile_currently_over = get_parent()
			#If the mouse button is lifted up the item should no longer follow the mouse
			elif(!event.pressed):
				if(follow_mouse):
					sprite.scale = Vector2(item_hovered_scale, item_hovered_scale)
				mouse_pressed = false
				follow_mouse = false
				#The item should attempt to be placed when the user lets go of it
				attempt_to_place()
		
func _process(delta: float) -> void:
	if(tooltip and mouse_over_item and !follow_mouse):
		if(current_time_till_tooltip > 0):
			current_time_till_tooltip -= delta
		else:
			if(tooltip.visible == false):
				tooltip.set_visible(true)
				#Play tooltip appear animation
				tooltip.get_node("AnimationPlayer").play("tooltip_appear")
	elif(tooltip and (!mouse_over_item or follow_mouse)):
		if(tooltip.visible == true):
			#Plays animation to popout tooltip. Once the animation finishes the tooltip turns itself off
			tooltip.get_node("AnimationPlayer").play("tooltip_popout")
		current_time_till_tooltip = show_tooltip_time
	if(follow_mouse):
		#Turn on the skill location tiles
		if(!play_skill_popout):
			play_skill_popout = true
			skill_tiles.get_node("AnimationPlayer").play("tilemap_popin")
		skill_tiles.global_position = sprite.global_position
		#Follow the mouse
		self.global_position = get_global_mouse_position()
		sprite.scale = Vector2(item_clicked_scale, item_clicked_scale)
		#If the item is currently over a tile
		if(tile_currently_over != null):
			#If the tile is empty 
			if(tile_currently_over.is_empty):
				#Snap to the tile location
				sprite.global_position = tile_currently_over.global_position
				unit_currently_over_can_upgrade = false
			#If the tile isnt empty 			
			#Check if its a unit which we can upgrade and is of the same type
			elif(!tile_currently_over.is_empty and tile_currently_over.units_on_tile[0].can_be_upgraded and tile_currently_over.units_on_tile[0].unit_ID == unit_ID):
				if(tile_currently_over.units_on_tile[0] != self):
					#Snap to the tile location
					sprite.global_position = tile_currently_over.global_position
					unit_currently_over_can_upgrade = true
			elif (tile_currently_over == self.get_parent()):
				if(tile_currently_over.units_on_tile[0] != self):
					#Snap to the tile location
					sprite.global_position = tile_currently_over.global_position
					unit_currently_over_can_upgrade = true
			#If the unit cant be upgraded or isnt the same unit or this item is a boost
			else:
				sprite.position = Vector2(0,0)
				unit_currently_over_can_upgrade = false
		#If there is no valid tile to snap to
		else:
			#Reset the sprite postion back to the parents position.
			#The parent is either following the mouse or set to the shop item location
			sprite.position = Vector2(0,0)
			unit_currently_over_can_upgrade = false
	else:
		self.position = Vector2(0,0)
		sprite.position = Vector2(0,0)
		unit_currently_over_can_upgrade = false
		if(skill_tiles and play_skill_popout):
			skill_tiles.get_node("AnimationPlayer").play("tilemap_popout")
			play_skill_popout = false
#Called when the player attempts to place the item on a tile
func attempt_to_place():
	#The player is trying to sell the item and the item has already been bought
	if(item_on_sell_location and bought):
		sell_item()	
	
	#If the item has been bought already
	if(bought):
		#If there is an available tile underneath the unit, then we can place it
		if(tile_currently_over != null and (tile_currently_over.is_empty or unit_currently_over_can_upgrade)):
			place_item()
		#If there is a unit on the tile, we can switch position with it
		elif(tile_currently_over != null and !tile_currently_over.is_empty):
			#Set other unit to move to our current tile
			var unit_to_swap_with = tile_currently_over.units_on_tile[0]
			unit_to_swap_with.reparent(self.get_parent())
			tile_currently_over.units_on_tile.erase(unit_to_swap_with)
			self.get_parent().unit_placed_on(unit_to_swap_with)
			unit_to_swap_with.position = Vector2(0,0)
			#Set our unit to the swapped units tile
			self.get_parent().units_on_tile.erase(self)
			self.reparent(tile_currently_over)
			self.get_parent().unit_placed_on(self)
			self.position = Vector2(0,0)
	else:
		if(shop_manager.money >= buy_cost):
			#If there is an available tile underneath the unit, then we can place it
			if(tile_currently_over != null and (tile_currently_over.is_empty or unit_currently_over_can_upgrade)):
				#Spend the money required to buy the item
				shop_manager.change_money(buy_cost)
				#Change the item to be bought
				bought = true
				cost_label.visible = false
				if(tile_currently_over.is_empty):
					place_item()
				else:
					place_item()
			#Not enough money or not a valid tile will reset the node back to the shop item locaiton
			else:
				#Resets position back to parent which is the item shop location or 
				self.position = Vector2(0,0)
#Called when an attempt_to_place is sucessful
func place_item():
	#Check if we are upgrading the unit below
	if(!unit_currently_over_can_upgrade):
		#If the unit is on a tile, set the tile to be empty when the unit is picked up
		if(self.get_parent().is_in_group("tile")):
			#Tell the tile that it no longer needs to keep track of the current unit
			self.get_parent().units_on_tile = []
			self.get_parent().is_empty = true
		#Set the units' parent to be the tile that it is placed on
		self.reparent(tile_currently_over)
		#Tells its new parent tile to set this item as being on it
		get_parent().unit_placed_on(self)
	#If we are then upgrade it
	else:
		tile_currently_over.units_on_tile[0].upgrade_unit(unit_ID, damage_boost, health_boost)
		if(get_parent().is_in_group("tile")):
			#Remove non-upgraded unit (self) from the tile
			get_parent().units_on_tile.erase(self)
			get_parent().is_empty = true
		queue_free()
	
#Called when the player sells the item
func sell_item():
	#Gives the player money for selling an item
	shop_manager.change_money(-sell_cost)
	#Deletes the item
	get_parent().is_empty = true
	get_parent().units_on_tile.erase(self)
	queue_free()


func upgrade_unit(ID, dmg_bst, hlth_bst):
	var dictionary_instance = dictionary.new()
	var upgraded_unit
	var new_ID : int
	#Two units on the same level
	if(ID == unit_ID):
		upgraded_unit = dictionary_instance.item_scenes[ID+1].instantiate()
		new_ID = ID + 1
	#Add the newly upgraded unit to the tile we are on
	get_parent().add_child(upgraded_unit)
	#Set the newly upgraded unit's position
	upgraded_unit.position = Vector2(0,0)
	#Purchase the unit
	upgraded_unit.bought = true
	#Turn off the coin visual
	upgraded_unit.cost_label.visible = false
	#Give the unit an ID
	upgraded_unit.unit_ID = new_ID
	#Sets the unit's types that buffs work against
	upgraded_unit.set_unit_buff_types()
	#Adds damage boost and health boost to self and then adds it to the new unit
	damage_boost += dmg_bst
	health_boost += hlth_bst
	upgraded_unit.damage_boost += damage_boost
	upgraded_unit.health_boost += health_boost
	#Updates the units labels
	upgraded_unit.set_labels()
	#Remove non-upgraded unit (self) from the tile
	get_parent().units_on_tile.erase(self)
	#Tell the tile that the upgraded unit has been placed on it
	get_parent().unit_placed_on(upgraded_unit)
	#Delete non-upgraded unit (self)
	queue_free()
func set_unit_buff_types():
	var dictionary_instance = dictionary.new()
	while unit_ID == -1:
		return
	var unit = dictionary_instance.unit_scenes[unit_ID].instantiate()
	buffs_work_against = unit.unit_types.duplicate()
	var potential_types = [Medieval,Army,Vehicle,Human,Soldier,Animal]
	var x = 0
	while(x < (potential_types.size())):
		if(!potential_types[x]):
			buffs_work_against[x] = null
		x += 1
func buff():
	if(can_buff):
		var buff_loc = 0
		while(buff_loc < buff_locations.size()):
			var unit = buff_locations[buff_loc].unit_to_buff
			if(unit != null and unit.bought):
				var dictionary_instance = dictionary.new()
				var unit_dictionary = dictionary_instance.unit_scenes[unit.unit_ID].instantiate()
				var can_buff_unit
				var b = 0
				while b < buffs_work_against.size():
					if(buffs_work_against[b] != null):
						if(unit_dictionary.get(buffs_work_against[b])):
							can_buff_unit = true
					b += 1
				if(can_buff_unit):
					if(damage_buff > 0):
						unit.damage_boost += damage_buff
						var buff_instance = damage_buff_visual.instantiate()
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(buff_instance)
						buff_instance.global_position = self.global_position
						buff_instance.unit = unit
						buff_instance.find_child("buff_text").text = str("+",damage_buff)
					if(health_buff > 0):
						unit.health_boost += health_buff
						var buff_instance = health_buff_visual.instantiate()
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(buff_instance)
						buff_instance.global_position = self.global_position
						buff_instance.unit = unit
						buff_instance.find_child("buff_text").text = str("+",health_buff)
			buff_loc += 1



func _on_area_2d_area_entered(area: Area2D) -> void:
	#If the area is a tile and the item is picked up, following the mouse
	if(area.is_in_group("tile") and follow_mouse):
		#Set the tile which we are currently over. This is so we can snap the 
		#Sprite2D to the tiles' location
		tile_currently_over = area.get_parent()
	#The player is holding the item over the sell area location
	elif(area.is_in_group("sell_location") and bought):
		item_on_sell_location = true
		#Set the cost label to the sell amount so we can see how much money we will get back
		cost_label.text = str(sell_cost)
		cost_label.visible = true
func _on_area_2d_area_exited(area: Area2D) -> void:
	#If the area we just left is the current tile the sprite is snapping to
	if(area.get_parent() == tile_currently_over):
		#We are no longer over the tile so unset it
		tile_currently_over = null
		unit_currently_over_can_upgrade = false
		#Reset the sprite position back to the parent node which is following
		#the mouse
		sprite.position = Vector2(0,0)
	#The player has stopped holding the item over the sell area location
	elif(area.is_in_group("sell_location") and bought):
		item_on_sell_location = false
		cost_label.visible = false
