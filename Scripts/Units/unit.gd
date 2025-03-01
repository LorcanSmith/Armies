extends Node

#Unit ID
@export var unit_ID : int = -1

#Does the unit move to defend empty columns
@export var defender : bool

#Damage done when brawling
@export var brawl_damage : int
#Units health
@export var health : int
#How much damage will be applied to this unit, this turn
var damage_done_to_self : int = 0

#Skill to spawn in
@export var skill_prefab : PackedScene
#The amount of damage/heals the unit's skill does
@export var skill_damage : int
@export var skill_heal : int

#The parent containing all the skill locations
@export var skill_locations_parent : Node2D

#Enemies inside our range
var enemies_in_range : int = 0

#Keep track of if the unit has moved this turn
var moved = false

var tile_to_move_to : Node2D

#Moves the unit in a desired direction and distance
func move():
	if(enemies_in_range == 0):
		#The unit has moved this turn
		moved = true
		#Set the parent to be the new tile
		reparent(tile_to_move_to)
		#Tell the new tile that this unit is now on it
		tile_to_move_to.unit_placed_on(self)
		#Set the units position to the new tile (units' parent)
		self.position = Vector2(0,0)

func skill():
	moved = false
	#If this unit is the only unit on the tile then they can do their skill
	if(get_parent().units_on_tile.size() == 1):
		#If there is at least one enemy within the units range (in a skill location)
		if(enemies_in_range > 0):
			#Spawn an instance of the skill at every skill location
			for location in skill_locations_parent.get_children():
				var skill_instance = skill_prefab.instantiate()
				#Tell the skill how much damage it does
				skill_instance.damage = skill_damage
				find_parent("combat_manager").find_child("skill_holder").add_child(skill_instance)
				#Set skills location to be at the correct spot
				skill_instance.global_position = location.global_position
				#Tell the skill if it is a friendly or enemy skill
				if(self.is_in_group("player")):
					skill_instance.belongs_to_player = true
				else:
					skill_instance.belongs_to_player = false
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


#Does damage to unit
func hurt(amount : int):
	damage_done_to_self += amount
	
#Heals unit
func heal(amount : int):
	damage_done_to_self -= amount

func apply_damage():
	health -= damage_done_to_self
	if(health <= 0):
		destroy_unit()
	damage_done_to_self = 0

#Called when the unit is destroyed
func destroy_unit():
	#Tells parent to remove this unit from its list of units on it
	get_parent().units_on_tile.erase(self)
	queue_free()

func _on_skill_area_2d_area_entered(area: Area2D) -> void:
	#Checking the area isnt a buff area
	if(!area.is_in_group("buff_location")):
		#If the area on our skill location is a unit of the opposite type
		if(self.is_in_group("player") and area.get_parent().is_in_group("enemy")):
			enemies_in_range += 1
		elif(self.is_in_group("enemy") and area.get_parent().is_in_group("player")):
			enemies_in_range += 1
func _on_skill_area_2d_area_exited(area: Area2D) -> void:
	#Checking the area isnt a buff area
	if(!area.is_in_group("buff_location")):
		#If the area on our skill location is a unit of the opposite type and it is no longer in range
		if(self.is_in_group("player") and area.get_parent().is_in_group("enemey")):
			enemies_in_range -= 1
		elif(self.is_in_group("enemy") and area.get_parent().is_in_group("player")):
			enemies_in_range -= 1

func _on_area_2d_area_entered(area: Area2D) -> void:
	#If the unit is in a buff location
	if(area.is_in_group("buff_location")):
		#Checks if the buff location belongs to an enemy
		if((self.is_in_group("player") and area.get_parent().get_parent().is_in_group("enemey")) or (self.is_in_group("enemy") and area.get_parent().get_parent().is_in_group("player"))):
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
		if((self.is_in_group("player") and area.get_parent().is_in_group("enemey")) or (self.is_in_group("enemy") and area.get_parent().is_in_group("player"))):
			#We have left the area so stop the weakening from working
			health += area.get_parent().health_weaken
			skill_damage += area.get_parent().damage_weaken
		#Checks if the buff belongs to a friendly
		elif((self.is_in_group("player") and area.get_parent().is_in_group("player")) or (self.is_in_group("enemy") and area.get_parent().is_in_group("enemy"))):
			#We have left the area so stop the weakening from working
			health -= area.get_parent().health_buff
			skill_damage -= area.get_parent().damage_buff
