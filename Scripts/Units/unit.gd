extends Node

#Unit ID - SET ID ON THE ITEM COUNTERPART
var unit_ID : int = -1
@export_group("Unit Properties")
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

##Damage done when brawling
@export var brawl_damage : int

##Damage done when pushed into a tile that isn't empty
@export	var bump_damage : int = 4

@export_subgroup("Unit Types")
var unit_types : Array = [
	"soldier",
	"animal"
]
@export var soldier : bool
@export var animal : bool
var potential_types : Array

#How much damage will be applied to this unit, this turn
var damage_done_to_self : int = 0

#where a unit is being pushed to
var pushed_destination : Node2D = null

#where a unit is being pushed to in Vector2i
var pushed_vector : Vector2i = Vector2i(0, 0)
@export_group("Skill Properties")
##Does the skill spawn at the units position (eg.Suicide robot)
@export var spawn_skill_on_self: bool
##How many skills will spawn
@export var skill_spawn_amount : int = 1
##Does the skill spawn at a random skill_location?
@export var skill_spawn_random : bool = false
##The amount of damage the unit's skill does
@export var skill_damage : int
##The amount of damage the unit's skill does
@export var skill_heal : int

@export var skill_pushes_units : bool = false

@export_subgroup("Skill Effective Against")
@export var effectiveness : int = 4
@export var soldier_effective : bool
@export var animal_effective : bool
var potential_skill_effective_types : Array
var effective_against_types : Array

#The parent containing all the skill locations
var skill_locations_parent : Node2D
#Skill to spawn in
var skill_prefab : PackedScene = load("res://Prefabs/Skills/basic_skill.tscn")
#Enemies inside our range
var enemies_in_range : Array = []

func _ready() -> void:
	skill_locations_parent = find_child("skill_locations")
	health = max_health
	movement_locations = find_child("movement_locations").get_children()
	if self.is_in_group("enemy"):
		$Label.modulate = Color(1, 0, 0, 1)
		$Label.position.y = -75
	update_label()
	set_unit_types()

func set_unit_types():
	effective_against_types = unit_types.duplicate()
	potential_types = [soldier, animal]
	potential_skill_effective_types = [soldier_effective, animal_effective]
	var x = 0
	while(x < (potential_types.size())):
		if(!potential_types[x]):
			unit_types[x] = null
		if(!potential_skill_effective_types[x]):
			effective_against_types[x] = null
		x += 1
	print("OUTPUT: ", effective_against_types)
func find_movement_tile():
	if(enemies_in_range.size() == 0):
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
	if(get_parent().units_on_tile.size() < 2):
		#If there is at least one enemy within the units range (in a skill location)
		if(enemies_in_range.size() > 0):

			var skills_spawned = 0
			#which enemy in enemies_in_range are we shooting
			var enemy_number = 0
			#Spawn an instance of the skill at every skill location
			while skills_spawned < skill_spawn_amount:
				if(enemy_number > enemies_in_range.size()-1):
					enemy_number = 0

				var skill_instance = skill_prefab.instantiate()
				#Tell the skill how much damage it does
				skill_instance.damage = skill_damage
				skill_instance.pushes_units = skill_pushes_units
				skill_instance.effective_against = effective_against_types
				skill_instance.effectiveness = effectiveness
				find_parent("combat_manager").find_child("skill_holder").add_child(skill_instance)

				#If the skill doesnt spawn randomly
				if(!skill_spawn_random):
					#Set skills location to be at the enemy location
					if spawn_skill_on_self:
						skill_instance.global_position = self.global_position
					else:
						skill_instance.global_position = enemies_in_range[enemy_number].global_position
				#If the skill spawns at a random location
				else:
					#Choose a random enemy in range
					var random_position = randi_range(0, enemies_in_range.size()-1)
					skill_instance.global_position = enemies_in_range[random_position].global_position

				#Tell the skill if it is a friendly or enemy skill
				if(self.is_in_group("player")):
					skill_instance.belongs_to_player = true
				else:
					skill_instance.belongs_to_player = false

				enemy_number += 1
				skills_spawned += 1

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
	if pushed_destination:
		print(self, pushed_vector)
		if pushed_vector != Vector2i(0, 0):
			get_parent().is_empty = true
			get_parent().units_on_tile.erase(self)
	#			place unit on new tile
			reparent(pushed_destination)
			#Tell the new tile that this unit is now on it
			pushed_destination.unit_placed_on(self)
			#Set the units position to the new tile (units' parent)
			self.position = Vector2(0,0)
		pushed_destination = null
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
	var can_be_pushed = false
#	units that are getting pushed into
	var collateral_units = []
	var push_locations = find_child("push_locations").get_children()
	var destination_tile = null
#	set a vector to account for multiple push forces
	if direction_pushed_from == "down":
		pushed_vector += Vector2i(0, 1)
		destination_tile = push_locations[0].tile_under_location
	elif direction_pushed_from == "left":
		pushed_vector += Vector2i(1, 0)
		destination_tile = push_locations[1].tile_under_location
	elif direction_pushed_from == "up":
		pushed_vector += Vector2i(0, -1)
		destination_tile = push_locations[2].tile_under_location
	elif direction_pushed_from == "right":
		pushed_vector += Vector2i(-1, 0)
		destination_tile = push_locations[3].tile_under_location
	
	if destination_tile != null:
		if destination_tile.is_empty:
			can_be_pushed = true
		else:
#			if units are on opposite teams, start a brawl
			if destination_tile.units_on_tile.size() == 1:
				if (destination_tile.units_on_tile[0].is_in_group("player") and
				self.is_in_group("enemy") or
				destination_tile.units_on_tile[0].is_in_group("enemy") and
				self.is_in_group("player")):
					can_be_pushed = true
				else:
#					friendly unit, both units take damage but no push
					collateral_units = destination_tile.units_on_tile
			else:
#				pushed into brawl square - no push but all units involved take damage
				collateral_units = destination_tile.units_on_tile
	if can_be_pushed:
		pushed_destination = destination_tile
		
	else:
		hurt(bump_damage)
		if collateral_units != []:
			var unit = 0
			while unit < collateral_units.size():
				collateral_units[unit].hurt(bump_damage)
				unit += 1


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

func _on_area_2d_area_entered(area: Area2D) -> void:
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
		if((self.is_in_group("player") and area.get_parent().get_parent().is_in_group("enemy")) or (self.is_in_group("enemy") and area.get_parent().get_parent().is_in_group("player"))):
			#We have left the area so stop the weakening from working	
			health += area.get_parent().health_weaken
			skill_damage += area.get_parent().damage_weaken
		#Checks if the buff belongs to a friendly
		elif((self.is_in_group("player") and area.get_parent().get_parent().is_in_group("player")) or (self.is_in_group("enemy") and area.get_parent().get_parent().is_in_group("enemy"))):
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
