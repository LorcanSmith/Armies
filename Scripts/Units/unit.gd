extends Node

#Unit ID - SET ID ON THE ITEM COUNTERPART
var unit_ID : int = -1

#Units max health 
@export var max_health : int
#Unit's current health
var health : int

#Keep track of if the unit has moved this turn
var moved = false
#Child node that contains all the locations the unit can move to
var movement_locations : Array = []
@export var move_distance : int = 1
var tile_to_move_to : Node2D

#Damage done when brawling
@export var brawl_damage : int


#How much damage will be applied to this unit, this turn
var damage_done_to_self : int = 0

##How many skills will spawn
@export var skill_spawn_amount : int = 1
##Does the skill spawn at a random skill_location?
@export var skill_spawn_random : bool = false
#The amount of damage/heals the unit's skill does
@export var skill_damage : int
@export var skill_heal : int


@export var skill_pushes_units : bool = false
#The parent containing all the skill locations
@export var skill_locations_parent : Node2D
#Skill to spawn in
@export var skill_prefab : PackedScene
#Enemies inside our range
var enemies_in_range : Array = []

func _ready() -> void:
	movement_locations = find_child("movement_locations").get_children()
	if self.is_in_group("enemy"):
		$Label.modulate = Color(1, 0, 0, 1)
		$Label.position.y = -75
	update_label()

func find_movement_tile():
	var moved_distance = 0
	#The unit has already found a tile this turn
	moved = true
	#Moves the unit forward until it has moved its maximum distance
	while(moved_distance < move_distance):
		#If the tile it is trying to move to is empty
		if(movement_locations[0].movement_tile != null and movement_locations[0].movement_tile.is_empty):
			#Sets the tile it wishes to move to
			tile_to_move_to = movement_locations[0].movement_tile
			#Tells the tile we're currently on to be empty
			get_parent().is_empty = true
			get_parent().units_on_tile.erase(self)
		#We have moved one unit
		moved_distance += 1
	#combat manager
	var combat_manager = find_parent("combat_manager")
	#Tell the combat manager that a unit has finished its "find tile" turn
	combat_manager.units_moved += 1
	#If the combat manager has no more units to find tiles for, then tell the manager to move the units
	if(combat_manager.units_moved >= combat_manager.units_to_move.size()):
		combat_manager.move_units()
		#Reset the counter for next time for which unit has to find a tile
		combat_manager.unit_to_find_tile = 0
	#There are still units to find tiles for
	else:
		#Tell the combat manager to find a tile for the next unit
		combat_manager.unit_to_find_tile += 1
		combat_manager.find_units_movement_tile()

#Moves the unit in a desired direction and distance
func move():
	if(enemies_in_range.size() == 0):
		if(tile_to_move_to != null):
			#Set the parent to be the new tile
			reparent(tile_to_move_to)
			#Tell the new tile that this unit is now on it
			tile_to_move_to.unit_placed_on(self)
			#Set the units position to the new tile (units' parent)
			self.position = Vector2(0,0)
	moved = false
func skill():
	#If this unit is the only unit on the tile then they can do their skill
	if(get_parent().units_on_tile.size() == 1):
		#If there is at least one enemy within the units range (in a skill location)
		if(enemies_in_range.size() > 0):
			var location = 0
			#Spawn an instance of the skill at every skill location
			while location < skill_spawn_amount:
				var skill_instance = skill_prefab.instantiate()
				#Tell the skill how much damage it does
				skill_instance.damage = skill_damage
				skill_instance.pushes_units = skill_pushes_units
				find_parent("combat_manager").find_child("skill_holder").add_child(skill_instance)
				if(!skill_spawn_random):
					#Set skills location to be at the correct spot
					skill_instance.global_position = skill_locations_parent.get_child(location).global_position
				else:
					var random_position = randi_range(0, skill_locations_parent.get_child_count())
					skill_instance.global_position = skill_locations_parent.get_child(random_position)
				#Tell the skill if it is a friendly or enemy skill
				if(self.is_in_group("player")):
					skill_instance.belongs_to_player = true
				else:
					skill_instance.belongs_to_player = false
				location += 1
	#If there is another unit on this tile then they will brawl
	else:
		brawl()

func brawl():
	print("BRAWL")
	#Finds each unit on this unit's current tile
	for unit in get_parent().units_on_tile:
		#If the unit isnt itself do some brawl damage to it
		if(unit != self):
			unit.hurt(brawl_damage)

func update_label():
	$Label.text = str(health) + "/" + str(max_health)

#Does damage to unit
func hurt(amount : int):
	damage_done_to_self += amount
	
#Heals unit
func heal(amount : int):
	damage_done_to_self -= amount

func apply_damage():
	health -= damage_done_to_self
	update_label()
	if(health <= 0):
		destroy_unit()
	damage_done_to_self = 0

#Called when the unit is destroyed
func destroy_unit():
	#Tells parent to remove this unit from its list of units on it
	get_parent().units_on_tile.erase(self)
	if(get_parent().units_on_tile.size() == 0):
		get_parent().is_empty = true
	queue_free()

func push(direction_pushed_from : String):
	#CODE TO PUSH PLAYER
	#Something like:
	#If direction_pushed_from == up:
	#check if the tile "down" is_empty
	#Each direction node will have to be set as a variable in this script
	
	#if the tile is empty, set this position to that tile
	#if it is not, deal some sorta damage to this unit and the unit on that tile
	
	#Also check if bool "inside_headquarter" is false on the push direction node
	#If its set to true, we're next to the headquarter and cant be pushed that direction
	pass


func _on_skill_area_2d_area_entered(area: Area2D) -> void:
	#Checking the area isnt a buff area
	if(!area.is_in_group("buff_location")):
		#If the area on our skill location is a unit of the opposite type
		if(self.is_in_group("player") and area.get_parent().is_in_group("enemy")):
			enemies_in_range.append(area.get_parent())
		elif(self.is_in_group("enemy") and area.get_parent().is_in_group("player")):
			enemies_in_range.append(area.get_parent())
func _on_skill_area_2d_area_exited(area: Area2D) -> void:
	#Checking the area isnt a buff area
	if(!area.is_in_group("buff_location")):
		#If the unit was in our range, remove it from our range
		if(enemies_in_range.has(area.get_parent())):
			enemies_in_range.erase(area.get_parent())

	if(area.is_in_group("buff_location")):
		#Checks if the buff location belongs to an enemy
		if((self.is_in_group("player") and area.get_parent().get_parent().is_in_group("enemy")) or (self.is_in_group("enemy") and area.get_parent().get_parent().is_in_group("player"))):
			#We have entered the area so apply weakening
			health -= area.get_parent().health_weaken
			skill_damage -= area.get_parent().damage_weaken
		#Checks if the buff belongs to a friendly
		elif((self.is_in_group("player") and area.get_parent().get_parent().is_in_group("player")) or (self.is_in_group("enemy") and area.get_parent().get_parent().is_in_group("enemy"))):
			#We have entered a buff location of a friendly so apply buffs
			health += area.get_parent().health_buff
			skill_damage += area.get_parent().damage_buff

func _on_area_2d_area_exited(area: Area2D) -> void:
	#If the unit is in a buff location
	if(area.is_in_group("buff_location")):
		#Checks if the buff location belongs to an enemy
		if((self.is_in_group("player") and area.get_parent().is_in_group("enemy")) or (self.is_in_group("enemy") and area.get_parent().is_in_group("player"))):
			#We have left the area so stop the weakening from working
			health += area.get_parent().health_weaken
			skill_damage += area.get_parent().damage_weaken
		#Checks if the buff belongs to a friendly
		elif((self.is_in_group("player") and area.get_parent().is_in_group("player")) or (self.is_in_group("enemy") and area.get_parent().is_in_group("enemy"))):
			#We have left the area so stop the weakening from working
			health -= area.get_parent().health_buff
			skill_damage -= area.get_parent().damage_buff

#Called when something enters one of the "push location" nodes
func _on_up_area_area_entered(area: Area2D) -> void:
	push_area_entered(area.get_parent(), "up")
func _on_right_area_area_entered(area: Area2D) -> void:
	push_area_entered(area.get_parent(), "right")
func _on_down_area_area_entered(area: Area2D) -> void:
	push_area_entered(area.get_parent(), "down")
func _on_left_area_area_entered(area: Area2D) -> void:
	push_area_entered(area.get_parent(), "left")

func push_area_entered(area, direction):
	#If the area is a skill
	if(area.is_in_group("skill")):
		#If that skill pushes units
		if(area.pushes_units):
			#If the skill belongs to an enemy
			if((self.is_in_group("player") and !area.belongs_to_player) or (self.is_in_group("enemy") and area.belongs_to_player)):
				#Tell the unit to push, from the direction the skill happend
				push(direction)
