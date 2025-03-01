extends Node

#Unit ID
@export var unit_ID : int = -1

#Keeps track of if the unit is on the same tile as an enemy (brawling)
var brawling = false
#Does the unit move to defend empty columns
@export var defender : bool

#Damage done when brawling
@export var brawl_damage : int
#Units health
@export var health : int

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

#Moves the unit in a desired direction and distance
func move(new_tile):
	#The unit has moved this turn
	moved = true
	#Set the parent to be the new tile
	reparent(new_tile)
	#Tell the new tile that this unit is now on it
	new_tile.unit_placed_on(self)
	#Set the units position to the new tile (units' parent)
	self.position = Vector2(0,0)
	print("MOVED")

func skill():
	moved = false
	print("SKILL")
	#If there is at least one enemy within the units range (in a skill location)
	if(enemies_in_range > 0):
		#Spawn an instance of the skill at every skill location
		for location in skill_locations_parent.get_children():
			var skill_instance = skill_prefab.instantiate()
			#Tell the skill how much damage it does
			skill_instance.damage = skill_damage
			self.add_child(skill_instance)
			#Set skills location to be at the correct spot
			skill_instance.global_position = location.global_position
			#Tell the skill if it is a friendly or enemy skill
			if(self.is_in_group("player")):
				skill_instance.belongs_to_player = true
			else:
				skill_instance.belongs_to_player = false

#Does damage to unit
func hurt(amount : int):
	health -= amount
	if(health <= 0):
		destroy_unit()
#Heals unit
func heal(amount : int):
	health += amount
	
#Called when the unit is destroyed
func destroy_unit():
	queue_free()

func _on_skill_area_2d_area_entered(area: Area2D) -> void:
	#If the area on our skill location is a unit of the opposite type
	if(self.is_in_group("player") and area.get_parent().is_in_group("enemy")):
		enemies_in_range += 1
	elif(self.is_in_group("enemy") and area.get_parent().is_in_group("player")):
		enemies_in_range += 1
		
func _on_skill_area_2d_area_exited(area: Area2D) -> void:
	#If the area on our skill location is a unit of the opposite type and it is no longer in range
	if(self.is_in_group("player") and area.get_parent().is_in_group("enemey")):
		enemies_in_range -= 1
	elif(self.is_in_group("enemy") and area.get_parent().is_in_group("player")):
		enemies_in_range -= 1
