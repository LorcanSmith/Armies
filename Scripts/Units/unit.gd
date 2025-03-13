extends Node

var alive : bool = true
#Unit ID - SET ID ON THE ITEM COUNTERPART
var unit_ID : int = -1
var tooltip : Control
var mouse_over : bool = false
@export var tooltip_show_time : float = 0.4
var current_tooltip_time_left
@export_group("Unit Properties")
#Units max health 
@export var max_health : int
#Unit's current health
var health : int
var health_bar_remaining : int
var health_bar : ColorRect
#Keep track of if the unit has moved this turn
var moved = false
#Child node that contains all the locations the unit can move to
var movement_locations : Array = []
@export var move_distance : int = 1
var tile_to_move_to : Node2D

##Damage done when brawling
@export var brawl_damage : int

@export_subgroup("Unit Types")
var unit_types : Array = [
	"Medieval",
	"Army",
	"Vehicle",
	"Human",
	"Soldier",
	"Animal"
]
@export var Medieval : bool
@export var Army : bool
@export var Vehicle : bool
@export var Human : bool
@export var Soldier : bool
@export var Animal : bool
var potential_types : Array

#How much damage will be applied to this unit, this turn
var damage_done_to_self : int = 0

@export_group("Skill Properties")
##Does the skill spawn at the units position (eg.Suicide robot)
@export var spawn_skill_on_self: bool
##How many skills will spawn
@export var skill_spawn_amount : int = 1
##Does the skill only spawn once on each enemy/friendly
@export var skill_max_once_per_unit : bool
##Does the skill spawn at a random skill_location?
@export var skill_spawn_random : bool
##The amount of damage the unit's skill does
@export var skill_damage : int
##The amount of damage the unit's skill does
@export var skill_heal : int
##If a unit is currently reloading
@export var reloading : bool
##The amount of time it takes for a unit to reload
@export var reload_time : int = 1

#internal timer that keeps track of a unit's current reload
var reloading_counter : int

@export var skill_shooots_closest_enemy : bool

@export_subgroup("Skill Projectile")
@export var projectile : PackedScene

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
#Friendlies inside our range
var friendlies_in_range : Array = []

func _ready() -> void:
	health_bar = find_child("health_bar_color")
	tooltip = find_child("Tooltip")
	current_tooltip_time_left = tooltip_show_time
	skill_locations_parent = find_child("skill_locations")

	health = max_health
	health_bar_remaining = max_health
	movement_locations = find_child("movement_locations").get_children()
	#Set tooltip
	find_child("Tooltip").update_tooltip()
	set_unit_types()

func set_unit_types():
	effective_against_types = unit_types.duplicate()
	potential_types = [Soldier, Animal]
	potential_skill_effective_types = [soldier_effective, animal_effective]
	var x = 0
	while(x < (potential_types.size())):
		if(!potential_types[x]):
			unit_types[x] = null
		if(!potential_skill_effective_types[x]):
			effective_against_types[x] = null
		x += 1
func find_movement_tile():
	if(enemies_in_range.size() == 0 or skill_damage <= 0):
		var moved_distance = 0
		#The unit has already found a tile this turn
		moved = true
		#Moves the unit forward until it has moved its maximum distance
		while(moved_distance < move_distance):
			#If the tile it is trying to move to is empty
			if(movement_locations[0].movement_tile != null and (movement_locations[0].movement_tile.is_empty or movement_locations[0].movement_tile.units_on_tile[0] == null)):
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
	if(enemies_in_range.size() == 0 or skill_damage <= 0):
		if(tile_to_move_to != null):
			#Set the parent to be the new tile
			reparent(tile_to_move_to)
			#Tell the new tile that this unit is now on it
			tile_to_move_to.unit_placed_on(self)
	moved = false
func skill():
	if reloading:
		reloading_counter -= 1
		if reloading_counter == 0:
			reloading = false
	#If this unit is the only unit on the tile then they can do their skill
	if(get_parent().units_on_tile.size() < 2):
		#If there is at least one enemy within the units range (in a skill location) and the unit isn't reloading
		if((enemies_in_range.size() > 0 or friendlies_in_range.size() > 0) and !reloading):
			var skills_spawned = 0
			#which unit in enemies_in_range/friendlies_in_range are we targeting
			var unit_number = 0
			#Spawn an instance of the skill at every skill location
			while skills_spawned < skill_spawn_amount:
				if((unit_number > enemies_in_range.size()-1 and skill_damage > 0) or (unit_number > friendlies_in_range.size()-1 and skill_heal > 0)):
					#If the skill can be spawned on each unit more than once
					if(!skill_max_once_per_unit):
						unit_number = 0
					else:
						break
				var skill_instance = skill_prefab.instantiate()
				#Tell the skill how much damage it does
				skill_instance.damage = skill_damage
				skill_instance.heal = skill_heal
				skill_instance.effective_against = effective_against_types
				skill_instance.effectiveness = effectiveness
				find_parent("combat_manager").find_child("skill_holder").add_child(skill_instance)
				
				if reload_time > 1:
					reloading = true
					reloading_counter = reload_time
				
				#If the skill doesnt spawn randomly
				if(!skill_spawn_random):
					#Set skills location to be at a random enemy location
					if spawn_skill_on_self:
						skill_instance.global_position = self.global_position
					#Sets skill's location to be at the closest enemy location
					elif(skill_shooots_closest_enemy):
						if(skill_damage > 0):
							skill_instance.global_position = enemies_in_range[0].global_position
							attack_visuals(enemies_in_range[0])
						elif(skill_heal > 0):
							skill_instance.global_position = friendlies_in_range[0].global_position
							attack_visuals(friendlies_in_range[0])
					#Loops through all enemies and sets the skill to be there location
					else:
						if(skill_damage > 0):
							skill_instance.global_position = enemies_in_range[unit_number].global_position
							attack_visuals(enemies_in_range[unit_number])
						elif(skill_heal > 0):
							skill_instance.global_position = friendlies_in_range[unit_number].global_position
							attack_visuals(friendlies_in_range[unit_number])
				#If the skill spawns at a random location
				else:
					#Choose a random enemy in range
					var random_position = randi_range(0, enemies_in_range.size()-1)
					skill_instance.global_position = enemies_in_range[random_position].global_position
					attack_visuals(enemies_in_range[random_position])
				#Tell the skill if it is a friendly or enemy skill
				if(self.is_in_group("player")):
					skill_instance.belongs_to_player = true
				else:
					skill_instance.belongs_to_player = false

				unit_number += 1
				skills_spawned += 1
		#No units in range or reloading
		else:
			#Check if there is a unit in front of you
			if(movement_locations[0].movement_tile != null and movement_locations[0].movement_tile.units_on_tile.size() > 0):
				#Unit on the tile in front of you
				var unit_in_front = movement_locations[0].movement_tile.units_on_tile[0]
				#Check if the unit front of you in an enemy
				if((unit_in_front and unit_in_front.is_in_group("enemy") and self.is_in_group("player")) or (unit_in_front and unit_in_front.is_in_group("player") and self.is_in_group("enemy"))):
					#Do brawl damage to the enemy in front of you
					unit_in_front.hurt(brawl_damage)
	#If there is another unit on this tile then they will brawl
	else:
		brawl()

func brawl():
	#Finds each unit on this unit's current tile
	for unit in get_parent().units_on_tile:
		#If the unit isnt itself do some brawl damage to it
		if(unit and unit != self):
			unit.hurt(brawl_damage)
			attack_visuals(unit)

func projectile_hit(amount : int):
	if(alive):
		health_bar_remaining -= amount
		if(health_bar_remaining < 0):
			health_bar_remaining = 0
		elif(health_bar_remaining > max_health):
			health_bar_remaining = max_health
		#Update health bar
		var percentage_of_health_reamining = float(health_bar_remaining)/float(max_health)
		
		health_bar.scale.x = 1 * percentage_of_health_reamining
		if(health_bar.scale.x < 0):
			health_bar.scale.x = 0
		if(health_bar_remaining <= 0):
			alive = false
			destroy_unit()
		else:
			if(amount > 0):
				#Play animation to show the unit has been hurt
				self.get_node("AnimationPlayer").play("unit_damage")
			if(amount < 0):
				#Play animation to show the unit has been healed
				self.get_node("AnimationPlayer").play("unit_heal")
	damage_done_to_self = 0
func attack_visuals(enemy : Node2D):
	#Projectile
	if(projectile):
		var projectile_instance = projectile.instantiate()
		find_parent("combat_manager").find_child("skill_holder").add_child(projectile_instance)
		projectile_instance.global_position = self.global_position
		projectile_instance.target_enemy(enemy)
		if(skill_damage > 0):
			projectile_instance.damage = skill_damage
		elif(skill_heal > 0):
			projectile_instance.damage = -skill_heal
	else:
		print(self.name)
#Does damage to unit
func hurt(amount : int):
	damage_done_to_self += amount
	
#Heals unit
func heal(amount : int):
	damage_done_to_self -= amount

func apply_damage():
	health -= damage_done_to_self
	damage_done_to_self = 0
	if(health > max_health):
		health = max_health

#Called when the unit is destroyed
func destroy_unit():
	#Tells parent to remove this unit from its list of units on it
	get_parent().units_on_tile.erase(self)
	if(get_parent().units_on_tile.size() == 0):
		get_parent().is_empty = true
	#Reparent to skill holder so the game waits for the unit to die
	self.reparent(find_parent("combat_manager").find_child("skill_holder"))
	#SOnce the damage animation plays, it will be destroyed
	self.get_node("AnimationPlayer").play("unit_damage")

func _on_skill_area_2d_area_entered(area: Area2D) -> void:
#	check if skill is meant to be used on allies or enemies
	if(skill_damage > 0):
		#If the area on our skill location is a unit of the opposite type
		if(self.is_in_group("player") and area.get_parent().is_in_group("enemy")):
			enemies_in_range.append(area.get_parent())
		elif(self.is_in_group("enemy") and area.get_parent().is_in_group("player")):
			enemies_in_range.append(area.get_parent())
	if(skill_heal > 0):
		##If the area on our skill location is a unit of the same type
		if((self.is_in_group("player") and area.get_parent().is_in_group("player")) or (self.is_in_group("enemy") and area.get_parent().is_in_group("enemy"))):
			friendlies_in_range.append(area.get_parent())
			
			
func _on_skill_area_2d_area_exited(area: Area2D) -> void:
	#If the unit was in our range, remove it from our range
	if(enemies_in_range.has(area.get_parent())):
		enemies_in_range.erase(area.get_parent())
	if(friendlies_in_range.has(area.get_parent())):
		friendlies_in_range.erase(area.get_parent())

#TOOL TIP STUFF
func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
func _on_area_2d_mouse_exited() -> void:
	mouse_over = false

func _process(delta: float) -> void:
	#If the unit isnt where it should be, then move it
	if(self.position != Vector2(0,0) and alive):
		#Moves the unit smoothly
		self.position = lerp(self.position, Vector2(0,0), delta*5)
	if(mouse_over and current_tooltip_time_left < 0):
		tooltip.set_visible(true)
	elif(mouse_over and current_tooltip_time_left > 0):
		current_tooltip_time_left -= delta
	if(!mouse_over):
		current_tooltip_time_left = tooltip_show_time
		tooltip.set_visible(false)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#If the unit is dead and the damage animation has played, destroy this unit
	if(!alive and anim_name == "unit_damage"):
		queue_free()
