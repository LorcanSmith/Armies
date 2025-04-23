extends Node2D


#Unit dictionary, used to spawn in upgraded units
var dictionary = preload("res://Scripts/Units/dictionary.gd")
#Unit ID, refer to UNIT ID document
#Items that aren't units do not need an ID
var unit_ID : int = -1

var disabled : bool = false
@export var show_tooltip_time : float = 1.4
var current_time_till_tooltip : float
var tooltip : Node2D
@export_group("Unit Info")
#damage and health gained from buffs
var damage_boost : int
var health_boost : int
@export var description : String
@export var before_combat_desc : String
@export var start_of_shop_desc : String

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
var bought : bool = true

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

@export_group("Item Abilities")
@export var increase_higher_level_unit_perecentage : float

@export_group("Item buffs")
##Is this item a boost item
@export var can_buff : bool
@export var damage_buff : int
@export var health_buff : int
#locations where buffs happen
var buff_location : Node2D
#locations where skills happen
var skill_location : Node2D
var locations_popped_in = false

#Visual that spawns to show a buff being done
var damage_buff_visual = preload("res://Prefabs/Effects/Buffs/buff_damage.tscn")
var health_buff_visual = preload("res://Prefabs/Effects/Buffs/buff_health.tscn")
var buffs_work_against : Array = []
@export_subgroup("Buffs work for")
@export var All : bool
@export var Medieval : bool
@export var Army : bool
@export var Vehicle : bool
@export var Human : bool
@export var Soldier : bool
@export var Animal : bool


var item_has_transformed : bool

var attack_label : Label = find_child("Attack")
var defense_label : Label = find_child("Defense")
func _ready() -> void:
	buff_location = find_child("buffs")
	skill_location = find_child("skills")
	upgrade_arrow = find_child("upgrade_arrow")
	
	sprite = find_child("Sprite2D")
	shop_manager = find_parent("shop_manager")
	tooltip = shop_manager.find_child("Tooltip")
	level_label = find_child("Level")
	cost_label = find_child("Cost")
	
	find_child("shadow").texture = find_child("Sprite2D").texture
	
	set_labels()
	set_unit_buff_types()
	get_node("AnimationPlayer").play("item_appear")

	current_time_till_tooltip = show_tooltip_time
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
	
func update_label_text():
	attack_label = find_child("Attack")
	defense_label = find_child("Defense")
	var dictionary_instance = dictionary.new()
	cost_label = find_child("Cost")
	var unit = dictionary_instance.unit_scenes[unit_ID].instantiate()
	attack_label.text = str(unit.skill_damage + damage_boost)
	defense_label.text = str(unit.max_health + health_boost)
	cost_label.text = str(buy_cost)
	
	#Sets the skill_locations to be green if they heal friendlies
	var x = 0
	while x < skill_location.get_child_count():
		if(unit.skill_heal > 0):
			var location_sprite = skill_location.get_child(x).find_child("location_sprite")
			location_sprite.find_child("sword").visible = false
			location_sprite.find_child("cross").visible = true
		x+= 1
	#If the item is in the shop we should check if it needs transforming
	if(!bought and !item_has_transformed):
		transform_item(unit)	
func transform_item(unit):
	attack_label = find_child("Attack")
	defense_label = find_child("Defense")
	if(!item_has_transformed):
		#Checks for transforming various items
		if(unit_name == "Werewolf"):
			if(find_parent("game_manager").turn_number % 2 == 0):
				find_child("Sprite2D").texture = unit.transform_sprite
				var doubled_attack = (unit.skill_damage + damage_boost) * 2
				var doubled_health = (unit.max_health + health_boost) * 2
				damage_boost = doubled_attack - unit.skill_damage
				health_boost = doubled_health - unit.max_health
				attack_label.text = str(doubled_attack)
				defense_label.text = str(doubled_health)
			elif(find_parent("game_manager").turn_number % 2 != 0 and bought):
				find_child("Sprite2D").texture = unit.regular_sprite
				damage_boost = (damage_boost - unit.skill_damage) / 2
				health_boost = (health_boost - unit.max_health) / 2
				attack_label.text = str(unit.skill_damage + damage_boost)
				defense_label.text = str(unit.max_health + health_boost)
		item_has_transformed = true
func toggle_skill_location():
	if(!disabled):
		#If the locations haven't been popped in yet, then turn them on and play an animation
		if(!locations_popped_in):
			#Turn on the buff/skill location tiles
			var x = 0
			while x < buff_location.get_child_count():
				buff_location.get_child(x).visible = true
				buff_location.get_child(x).get_node("AnimationPlayer").play("location_popin")
				x += 1
			x = 0
			while x < skill_location.get_child_count():
				skill_location.get_child(x).visible = true
				skill_location.get_child(x).get_node("AnimationPlayer").play("location_popin")
				x += 1
			x = 0
			locations_popped_in = true
		#If the locations are visible and popped in then play animation to pop them out
		#The locations themselves will set to be invisible when the animation finishes
		elif(locations_popped_in):
			#Turn off buff/skill location visuals
			locations_popped_in = false
			var x = 0
			while x < buff_location.get_child_count():
				buff_location.get_child(x).get_node("AnimationPlayer").play("location_popout")
				x += 1
			x = 0
			while x < skill_location.get_child_count():
				skill_location.get_child(x).get_node("AnimationPlayer").play("location_popout")
				x += 1
#Called when the mouse is hovering over
func _on_area_2d__mouse_collision_mouse_entered() -> void:
	if(!disabled):
		if(!mouse_pressed):
			mouse_over_item = true
			shop_manager.show_potential_upgrades(true,self)
			sprite.scale = Vector2(item_hovered_scale,item_hovered_scale)
		#If the locations haven't been popped in yet, then turn them on and play an animation
		if(bought):
			toggle_skill_location()
#Called when the mouse stops hovering over
func _on_area_2d__mouse_collision_mouse_exited() -> void:
	if(!disabled):
		tooltip.hide_tooltip = true
		if(!mouse_pressed):
			mouse_over_item = false
			shop_manager.show_potential_upgrades(false,self)
			sprite.scale = Vector2(1,1)
		if(bought):
			toggle_skill_location()
	current_time_till_tooltip = show_tooltip_time
	
#Checks to see if the mouse is clicked. This is so we can check to see if a user
#has clicked on an item.
func _input(event):
	if(!disabled):
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
						if(!bought and !locations_popped_in):
							toggle_skill_location()
				#If the mouse button is lifted up the item should no longer follow the mouse
				elif(!event.pressed):
					if(follow_mouse):
						sprite.scale = Vector2(item_hovered_scale, item_hovered_scale)
					mouse_pressed = false
					follow_mouse = false
					
					#The item should attempt to be placed when the user lets go of it
					attempt_to_place()
		
func _process(delta: float) -> void:
	if(!disabled):
		if(follow_mouse):
			#Pop tool tip out
			tooltip.update_tooltip(-1, 0 ,0)
			current_time_till_tooltip = show_tooltip_time
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
			if(sprite.scale == Vector2(item_hovered_scale, item_hovered_scale) and current_time_till_tooltip > 0 and tooltip.visible == false):
				current_time_till_tooltip -= delta
			elif(sprite.scale == Vector2(item_hovered_scale, item_hovered_scale) and tooltip.visible and (tooltip.current_unit_ID != unit_ID or !tooltip.currently_showing_unit)):
				#Update tool tip
				tooltip.update_tooltip(unit_ID, damage_boost, health_boost)
			elif(sprite.scale == Vector2(item_hovered_scale, item_hovered_scale) and current_time_till_tooltip <= 0 and tooltip.visible == false):
				#Update tool tip
				tooltip.update_tooltip(unit_ID, damage_boost, health_boost)
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
		elif(tile_currently_over != null and !tile_currently_over.is_empty and get_parent().is_in_group("tile")):
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
				if(locations_popped_in):
					toggle_skill_location()
		else:
			if(locations_popped_in):
				toggle_skill_location()
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
	#Tell the sell location that an item has been sold
	shop_manager.find_child("sell_location").item_sold(sell_cost)
	#Deletes the item
	if(get_parent().is_in_group("tile")):
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
	#Tells the new item to check if it should transform into something else
	var unit_for_checking_transforming = dictionary_instance.unit_scenes[ID+1].instantiate()
	upgraded_unit.transform_item(unit_for_checking_transforming)
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
	while unit_ID == -1:
		return
	#Spawns an instance of the unit so we can access types
	var dictionary_instance = dictionary.new()
	var unit = dictionary_instance.unit_scenes[unit_ID].instantiate()
	#Copy a list of every potential type
	buffs_work_against = unit.unit_types.duplicate()
	var x = 0
	while(x < (buffs_work_against.size())):
		#If the bool with the same name as buffs_work_against[x] is equal to false the remove it
		var buff_bool = get(buffs_work_against[x])
		if(!buff_bool):
			buffs_work_against[x] = null
		x += 1
	
func buff():
	if(can_buff):
		var buff_loc = 0
		while(buff_loc < buff_location.get_child_count()):
			var unit = buff_location.get_child(buff_loc).unit_to_buff
			if(unit != null and unit.bought):
				var dictionary_instance = dictionary.new()
				var unit_dictionary = dictionary_instance.unit_scenes[unit.unit_ID].instantiate()
				var can_buff_unit
				var b = 0
				if(!All):
					while b < buffs_work_against.size():
						if(buffs_work_against[b] != null):
							if(unit_dictionary.get(buffs_work_against[b])):
								can_buff_unit = true
						b += 1
				else:
					can_buff_unit = true
				if(can_buff_unit):
					if(damage_buff > 0 or damage_buff < 0):
						#Delay so the buffs don't all appear at the same time
						await get_tree().create_timer(randf_range(0.05, 0.25)).timeout
						unit.damage_boost += damage_buff
						var buff_instance = damage_buff_visual.instantiate()
						find_parent("shop_manager").find_child("buff_animation_holder").add_child(buff_instance)
						buff_instance.global_position = self.global_position
						buff_instance.unit = unit
						buff_instance.find_child("buff_text").text = str("+",damage_buff)
					if(health_buff > 0 or health_buff < 0):
						#Delay so the buffs don't all appear at the same time
						await get_tree().create_timer(randf_range(0.05, 0.25)).timeout
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
		#Make the sell location slightly bigger
		area.get_parent().scale = Vector2(1.2,1.2)
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
		#Make the sell location size back to normal
		area.get_parent().scale = Vector2(1,1)


var coin : PackedScene = preload("res://Prefabs/Effects/UI/coin_effect.tscn")
func spawn_coin(amount):
	var coins_left = amount
	while coins_left > 0:
		var c = coin.instantiate()
		find_parent("shop_manager").find_child("buff_animation_holder").add_child(c)
		c.global_position = self.global_position
		c.global_position.x += randf_range(-10,10)
		c.global_position.y += randf_range(-10,10)
		coins_left -= 1
		await get_tree().create_timer(0.1).timeout
