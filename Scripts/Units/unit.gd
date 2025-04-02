extends Node
var combat_manager : Node2D
var alive : bool = true
#Unit ID - SET ID ON THE ITEM COUNTERPART
var unit_ID : int = -1
var tooltip : Node2D
#How much damage and health is "buffed-on" compared to the base unit, used for tooltip
var damage_boost : int
var health_boost : int

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
var ammo_bar : ColorRect
#Keep track of if the unit has moved this turn
var moved = false
#Child node that contains all the locations the unit can move to
var movement_locations : Array = []
@export var move_distance : int = 1
var tile_to_move_to : Node2D

##Damage done when brawling
@export var brawl_damage : int
#brawl sprite
var brawl_effect : PackedScene = preload("res://Prefabs/Effects/brawl_effect.tscn")
var current_brawl_effect = null
var brawling_grid : Node2D
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
##skill does splash damage
@export var skill_does_splash : bool

#internal holder for enemies in splash zone
var enemies_in_splash_zone : Array

#internal timer that keeps track of a unit's current reload
var reloading_counter : int

@export var skill_shooots_closest_enemy : bool

@export_subgroup("Skill Projectile")
@export var projectile : PackedScene

@export_subgroup("Skill Effective Against")
@export var effectiveness : int = 4
@export var Soldier_effective : bool
@export var Animal_effective : bool
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
	combat_manager = find_parent("combat_manager")
	health_bar = find_child("health_bar_color")
	ammo_bar = find_child("ammo_bar_color")
	if skill_does_splash:
		skill_prefab = load("res://Prefabs/Skills/splash_skill.tscn")
		
	if reload_time > 1:
		find_child("ammo_bar_background").visible = true
	current_tooltip_time_left = tooltip_show_time
	skill_locations_parent = find_child("skill_locations")

	health_bar_remaining = max_health
	movement_locations = find_child("movement_locations").get_children()
	#Set tooltip
	tooltip = combat_manager.find_child("Tooltip")
	set_level_chevron()
	set_unit_types()

func set_damage_and_health(dmg, hlth):
	damage_boost = dmg
	health_boost = hlth
	skill_damage += dmg
	max_health += hlth
	health = max_health
	
func set_level_chevron():
	var level_chevron_parent = find_child("level_chevrons")
	if(unit_ID % 3 == 0):
		level_chevron_parent.get_child(0).visible = true
	elif(unit_ID % 3 == 1):
		level_chevron_parent.get_child(0).visible = true
		level_chevron_parent.get_child(1).visible = true
	elif(unit_ID % 3 == 2):
		level_chevron_parent.get_child(0).visible = true
		level_chevron_parent.get_child(1).visible = true
		level_chevron_parent.get_child(2).visible = true
func set_unit_types():
	#Gets all the unit types
	effective_against_types = unit_types.duplicate()
	var x = 0
	while(x < unit_types.size()):
		#Finds the boolean with the same name as unit_types[x]
		var type = get(unit_types[x])
		var effective_against_type = get(unit_types[x] + "_effective")
		#If the bool is set to false then it isnt of this type and should be removed from the list
		if(!type):
			unit_types[x] = null
		if(!effective_against_type):
			effective_against_types[x] = null
		x+=1
	
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

var mo = false
#Moves the unit in a desired direction and distance
func move():
	#Deletes brawl effect if any exists
	if(current_brawl_effect != null):
		current_brawl_effect.queue_free()
	if(enemies_in_range.size() == 0 or skill_damage <= 0):
		if(tile_to_move_to != null):
			#Set the parent to be the new tile
			reparent(tile_to_move_to)
			#Tell the new tile that this unit is now on it
			tile_to_move_to.unit_placed_on(self)
			mo = true
			#if(current_brawl_effect == null && get_parent().units_on_tile.size() == 2):
				#current_brawl_effect = brawl_effect.instantiate()
				#get_parent().add_child(current_brawl_effect)
				#current_brawl_effect.global_position = Vector2(get_parent().global_position.x, get_parent().global_position.y)
	if(!mo):
		combat_manager.w += 1
		combat_manager.waited_for_move()
	moved = false
	
func skill(phase : String):
	#If this unit is the only unit on the tile then they can do their skill
	if(alive and get_parent().units_on_tile.size() < 2):
		if((phase == "combat_phase" and skill_damage > 0) or (phase == "healing_phase" and skill_heal > 0)):
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
				
				#Tell the skill if it is a friendly or enemy skill
				if(self.is_in_group("player")):
					skill_instance.belongs_to_player = true
				else:
					skill_instance.belongs_to_player = false
				
				if reload_time > 1:
					reloading = true
					reloading_counter = reload_time
				
				#If the skill doesnt spawn randomly
				if(!skill_spawn_random):
					#Set skills location to be at current position
					if spawn_skill_on_self:
						skill_instance.global_position = self.global_position
					#Sets skill's location to be at the closest enemy location
					elif(skill_shooots_closest_enemy):
						if !skill_does_splash:
							if(skill_damage > 0):
								skill_instance.global_position = enemies_in_range[0].global_position
								attack_visuals(enemies_in_range[0])
							elif(skill_heal > 0):
								skill_instance.global_position = friendlies_in_range[0].global_position
								attack_visuals(friendlies_in_range[0])
						else:
							if(skill_damage > 0):
								skill_instance.global_position = enemies_in_range[0].global_position
								attack_visuals(enemies_in_range[0])
							elif(skill_heal > 0):
								skill_instance.global_position = friendlies_in_range[0].global_position
								var friendly_areas = skill_instance.get_node("Area2D").get_overlapping_areas()
								for area in friendly_areas:
									if (self.is_in_group("player") and area.get_parent().is_in_group("player")) or (self.is_in_group("enemy") and area.get_parent().is_in_group("enemy")):
										enemies_in_splash_zone.append(area.get_parent())
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
	
	if reloading:
		reloading_counter -= 1
		var ammo_cooldown = float((reload_time - reloading_counter)-1)/float(reload_time - 1)
		ammo_bar.scale.x = 1 * ammo_cooldown
		if reloading_counter == 0:
			reloading = false

func brawl():
	if(alive):
		brawling_grid = get_parent()
	#Finds each unit on this unit's current tile
	for unit in brawling_grid.units_on_tile:
		#If the unit isnt itself do some brawl damage to it
		if(unit and unit != self):
			unit.hurt(brawl_damage)
			unit.projectile_hit(brawl_damage)

func projectile_hit(amount : int):
	if(alive):
		var needs_healing = false
		if health_bar_remaining < max_health:
			needs_healing = true
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
			if(amount < 0 and needs_healing):
				#Play animation to show the unit has been healed
				self.get_node("AnimationPlayer").play("unit_heal")
	damage_done_to_self = 0

func attack_visuals(enemy : Node2D):
	#Projectile
	if(projectile):
		var projectile_instance = projectile.instantiate()
		find_parent("combat_manager").find_child("skill_holder").add_child(projectile_instance)
		projectile_instance.global_position = self.global_position
		if(skill_damage > 0):
			projectile_instance.damage = skill_damage
		elif(skill_heal > 0):
			projectile_instance.damage = -skill_heal
		if skill_does_splash:
			projectile_instance.enemies_in_splash_zone = enemies_in_splash_zone
		projectile_instance.target_enemy(enemy)
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
	#Get the grid we are currently on so we can apply damage to brawling units before we die
	brawling_grid = get_parent()
	#Reparent to skill holder so the game waits for the unit to die
	self.reparent(find_parent("combat_manager").find_child("skill_holder"))
	#SOnce the damage animation plays, it will be destroyed
	self.get_node("AnimationPlayer").play("unit_damage")

func skill_area_entered(area: Area2D) -> void:
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
			
			
func skill_area_exited(area: Area2D) -> void:
	#If the unit was in our range, remove it from our range
	if(enemies_in_range.has(area.get_parent())):
		enemies_in_range.erase(area.get_parent())
	if(friendlies_in_range.has(area.get_parent())):
		friendlies_in_range.erase(area.get_parent())

#TOOL TIP STUFF
func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
	#Pop tooltip in if the tooltip is hidden
	if(tooltip.visible == false):
		tooltip.visible = true
		tooltip.get_node("AnimationPlayer").play("tooltip_appear")
	else:
		tooltip.get_node("AnimationPlayer").play("tooltip_refresh")
func _on_area_2d_mouse_exited() -> void:
	mouse_over = false

func _process(delta: float) -> void:
	#If the unit isnt where it should be, then move it
	if(self.position != Vector2(0,0) and alive):
		#Moves the unit smoothly
		self.position = lerp(self.position, Vector2(0,0), delta*5)
	if(self.position.distance_to(Vector2(0,0)) < 1.8 and mo):
		mo = false
		combat_manager.w += 1
		combat_manager.waited_for_move()
	if(mouse_over):
		tooltip.update_tooltip(unit_ID, damage_boost ,health_boost)
		var x = 0
		while x < skill_locations_parent.get_child_count():
			if(skill_locations_parent.get_child(x).visible == false):
				skill_locations_parent.get_child(x).visible = true
				skill_locations_parent.get_child(x).get_node("AnimationPlayer").play("location_popin")
			x += 1
	if(!mouse_over):
		#Plays animation to popout tooltip. Once the animation finishes the tooltip turns itself off
		#tooltip.get_node("AnimationPlayer").play("tooltip_popout")
		#Turns on skill locations
		var x = 0
		while x < skill_locations_parent.get_child_count():
			skill_locations_parent.get_child(x).get_node("AnimationPlayer").play("location_popout")
			x += 1

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#If the unit is dead and the damage animation has played, destroy this unit
	if(!alive and anim_name == "unit_damage"):
		queue_free()


func _on_splash_location_area_entered(area):
	if (self.is_in_group("player") and area.get_parent().is_in_group("enemy")) or (self.is_in_group("enemy") and area.get_parent().is_in_group("player")):
		enemies_in_splash_zone.append(area.get_parent())


func _on_splash_location_area_exited(area):
	enemies_in_splash_zone.erase(area.get_parent())
