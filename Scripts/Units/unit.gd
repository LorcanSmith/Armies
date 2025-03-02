extends Node

#Unit ID
@export var unit_ID : int = -1

#Does the unit move to defend empty columns
@export var defender : bool

#Damage done when brawling
@export var brawl_damage : int

#Units max health 
@export var max_health : int

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
var enemies_in_range : Array = []

#Keep track of if the unit has moved this turn
var moved = false

var tile_to_move_to : Node2D

func _ready():
	update_label()

#Moves the unit in a desired direction and distance
func move():
	if(enemies_in_range.size() == 0):
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
		if(enemies_in_range.size() > 0):
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
		#print(get_parent().units_on_tile.size())
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
	#If the unit is in a buff location
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
