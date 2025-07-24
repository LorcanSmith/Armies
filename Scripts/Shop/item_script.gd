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
var current_health : int
var current_damage : int
@export var description : String
@export var before_combat_desc : String
@export var start_of_shop_desc : String

@export var unit_name : String
#The shop manager keeps track of player money
var shop_manager : Node2D
#How much it costs to buy the item
@export var buy_cost : int = 0
#How much money you get from selling the item
@export var sell_cost : int = 0
#Keeps track if the player has bought the unit yet. Stops the player from selling
#items that haven't been bought yet, as well as making sure the player pays for items
var bought : bool = false

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
var cost_label : Label

#Is the player currently hovering over the item, used to detect if they click on this item
var mouse_over_item : bool = false
#Should the item follow the mouse
var follow_mouse : bool = false
var mouse_pressed : bool = false

#item scale
var item_hovered_scale = 1.2
var item_clicked_scale = 1.4

##Does the unit leave blood on the ground
var leaves_blood_on_ground : bool = true
var blood_stain : Array = [preload("res://Prefabs/Effects/Stains/blood/blood_1.tscn")]
var explosion_stain : Array = [preload("res://Prefabs/Effects/Stains/residue/residue_1.tscn")]
##What particle effect does it use when it dies?
var particle_effect : PackedScene

@export_group("Item Abilities")

@export_group("Item buffs")
##Is this item a boost item
@export var can_buff : bool
@export var damage_buff : int
@export var health_buff : int
@export var retriggers_buffs : bool = false
#locations where buffs happen
var buff_location : Node2D
#locations where skills happen
var skill_location : Node2D
var locations_popped_in = false

#Visual that spawns to show a buff being done
var damage_buff_visual = preload("res://Prefabs/Effects/Buffs/buff_damage.tscn")
var health_buff_visual = preload("res://Prefabs/Effects/Buffs/buff_health.tscn")
var negative_health_buff_visual = preload("res://Prefabs/Effects/Buffs/negative_buff_health.tscn")
var buff_retrigger_visual = preload("res://Prefabs/Effects/Buffs/buff_retrigger.tscn")
var buffs_work_against : Array = []

#Used for skills that require taking damage to activate
var taken_damage : bool = false

@export_subgroup("Buffs work for")
@export var All : bool
@export_subgroup("Themes")
@export var Medieval : bool
@export var Army : bool
@export var Dinosaur : bool
@export var Fantasy : bool
@export var Scifi : bool
@export var Animal : bool
@export_subgroup("Types")
@export var Vehicle : bool
@export var Human : bool
@export var Healer : bool
@export_subgroup("Names")
@export var Soldier : bool
@export var Velociraptor : bool
@export var Dog : bool
@export var Sheep : bool
@export var Pig : bool


var item_has_transformed : bool = false

var attack_label : Label = find_child("Attack")
var defense_label : Label = find_child("Defense")
func _ready() -> void:
	buff_location = find_child("buffs")
	skill_location = find_child("skills")
	
	sprite = find_child("Sprite2D")
	shop_manager = find_parent("shop_manager")
	if(shop_manager):
		tooltip = shop_manager.find_child("Tooltip")
	cost_label = find_child("Cost")
		
	set_labels()
	set_unit_buff_types()
	get_node("AnimationPlayer").play("item_appear")

	current_time_till_tooltip = show_tooltip_time

func set_labels():
	if(unit_ID != -1):
		update_label_text()
	
func update_label_text():
	attack_label = find_child("Attack")
	defense_label = find_child("Defense")
	var dictionary_instance = dictionary.new()
	cost_label = find_child("Cost")
	var unit = dictionary_instance.unit_scenes[unit_ID].instantiate()
	
	leaves_blood_on_ground = unit.leaves_blood_on_ground
	blood_stain = unit.blood_stain
	explosion_stain = unit.explosion_stain
	particle_effect = unit.particle_effect
	
	attack_label.text = str(unit.skill_damage + damage_boost)
	defense_label.text = str(unit.max_health + health_boost)
	current_damage = unit.skill_damage + damage_boost
	current_health = unit.max_health + health_boost
	cost_label.text = str(buy_cost)
	
	#If the item is in the shop we should check if it needs transforming
	if(!bought):
		transform_item(unit)
	else:
		unit.queue_free()
	dictionary_instance.queue_free()
func transform_item(unit):
	attack_label = find_child("Attack")
	defense_label = find_child("Defense")
	#Checks for transforming various items
	if(unit_name == "Werewolf"):
		#Unit is a werewolf
		if(find_parent("game_manager").turn_number % 2 == 0):
			var doubled_attack = (unit.skill_damage + damage_boost) * 2
			var doubled_health = (unit.max_health + health_boost) * 2
			damage_boost = doubled_attack - unit.skill_damage
			health_boost = doubled_health - unit.max_health
			attack_label.text = str(doubled_attack)
			defense_label.text = str(doubled_health)
			current_health = doubled_health
			current_damage = doubled_attack
			get_node("Sprite2D/AnimatedSprite2D").play("idle_transformed")
			item_has_transformed = true
		#unit is a human
		elif(find_parent("game_manager").turn_number % 2 != 0 and bought):
			damage_boost = (damage_boost - unit.skill_damage) / 2
			health_boost = (health_boost - unit.max_health) / 2
			attack_label.text = str(unit.skill_damage + damage_boost)
			defense_label.text = str(unit.max_health + health_boost)
			current_health = unit.skill_damage + damage_boost
			current_damage = unit.max_health + health_boost
			item_has_transformed = false
	unit.queue_free()
func toggle_skill_location():
	if(!disabled):
		#If the locations haven't been popped in yet, then turn them on and play an animation
		if(!locations_popped_in and shop_manager.find_child("battle_button").visible):
			#Turn on the buff/skill location tiles
			var x = 0
			while x < buff_location.get_child_count():
				buff_location.get_child(x).visible = true
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
				buff_location.get_child(x).visible = false
				x += 1
			x = 0
			while x < skill_location.get_child_count():
				skill_location.get_child(x).get_node("AnimationPlayer").play("location_popout")
				x += 1
#Called when the mouse is hovering over
func _on_area_2d__mouse_collision_mouse_entered() -> void:
	if(!disabled):
		if(!mouse_pressed and shop_manager.find_child("battle_button").visible):
			mouse_over_item = true
			sprite.scale = Vector2(item_hovered_scale,item_hovered_scale)
		#If the locations haven't been popped in yet, then turn them on and play an animation
		if(!locations_popped_in):
			toggle_skill_location()
#Called when the mouse stops hovering over
func _on_area_2d__mouse_collision_mouse_exited() -> void:
	if(!disabled):
		tooltip.hide_tooltip = true
		if(!mouse_pressed):
			mouse_over_item = false
			sprite.scale = Vector2(1,1)
		if(locations_popped_in):
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
					if(mouse_over_item and shop_manager.find_child("battle_button").visible):
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
				#If the tile isnt empty 			
				elif (tile_currently_over == self.get_parent()):
					if(tile_currently_over.units_on_tile[0] != self):
						#Snap to the tile location
						sprite.global_position = tile_currently_over.global_position
				#If the unit cant be upgraded or isnt the same unit or this item is a boost
				else:
					sprite.position = Vector2(0,0)
			#If there is no valid tile to snap to
			else:
				#Reset the sprite postion back to the parents position.
				#The parent is either following the mouse or set to the shop item location
				sprite.position = Vector2(0,0)
		if(!follow_mouse and shop_manager.find_child("battle_button").visible):
			self.position = Vector2(0,0)
			sprite.position = Vector2(0,0)
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
		if(tile_currently_over != null and (tile_currently_over.is_empty)):
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
			if(tile_currently_over != null and (tile_currently_over.is_empty)):
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
	#If the unit is on a tile, set the tile to be empty when the unit is picked up
	if(self.get_parent().is_in_group("tile")):
		#Tell the tile that it no longer needs to keep track of the current unit
		self.get_parent().units_on_tile = []
		self.get_parent().is_empty = true
	#Set the units' parent to be the tile that it is placed on
	self.reparent(tile_currently_over)
	#Tells its new parent tile to set this item as being on it
	get_parent().unit_placed_on(self)
	
	
#Called when the player sells the item
func sell_item():
	#Tell the sell location that an item has been sold
	shop_manager.find_child("sell_location").item_sold(sell_cost)
	#Deletes the item
	if(get_parent().is_in_group("tile")):
		get_parent().is_empty = true
		get_parent().units_on_tile.erase(self)
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
	dictionary_instance.queue_free()
	unit.queue_free()
func buff():
	var dictionary_instance = dictionary.new()
	if(can_buff):
		var buff_loc = 0
		while(buff_loc < buff_location.get_child_count()):
			var unit = buff_location.get_child(buff_loc).unit_to_buff
			if(unit != null and unit.bought):
				var unit_dictionary = dictionary_instance.unit_scenes[unit.unit_ID].instantiate()
				var can_buff_unit = true
				if(check_if_can_buff_unit(unit_dictionary)):
					if(can_buff_unit):
						if(damage_buff > 0 or damage_buff < 0):
							unit.buff_unit_damage(damage_buff)
							var buff_instance = damage_buff_visual.instantiate()
							find_parent("shop_manager").find_child("buff_animation_holder").add_child(buff_instance)
							#Delay so the buffs don't all appear at the same time
							await get_tree().create_timer(randf_range(0.05, 0.6)).timeout
							buff_instance.global_position = self.global_position
							buff_instance.get_node("AnimationPlayer").play("buff_appear")
							buff_instance.unit = unit
							buff_instance.find_child("buff_text").text = str("+",damage_buff)
							get_node("item_buffs_anim_player").play("unit_buffs")
						if(health_buff > 0 or health_buff < 0):
							unit.buff_unit_health(health_buff)
							var buff_instance
							if(health_buff > 0):
								buff_instance = health_buff_visual.instantiate()
							elif(health_buff < 0):
								buff_instance = negative_health_buff_visual.instantiate()
							find_parent("shop_manager").find_child("buff_animation_holder").add_child(buff_instance)
							#Delay so the buffs don't all appear at the same time
							await get_tree().create_timer(randf_range(0.05, 0.6)).timeout
							buff_instance.global_position = self.global_position
							buff_instance.get_node("AnimationPlayer").play("buff_appear")
							buff_instance.unit = unit
							buff_instance.find_child("buff_text").text = str("+",health_buff)
							get_node("item_buffs_anim_player").play("unit_buffs")
						if(retriggers_buffs):
							var buff_instance
							buff_instance = buff_retrigger_visual.instantiate()
							find_parent("shop_manager").find_child("buff_animation_holder").add_child(buff_instance)
							#Delay so the buffs don't all appear at the same time
							await get_tree().create_timer(randf_range(0.05, 0.6)).timeout
							buff_instance.global_position = self.global_position
							buff_instance.get_node("AnimationPlayer").play("buff_appear")
							buff_instance.unit = unit
							unit.buff()
							get_node("item_buffs_anim_player").play("unit_buffs")
						##Activates unit abilities in shop
						activate_any_abilities(unit, unit.unit_ID)
			buff_loc += 1
	dictionary_instance.queue_free()

#Activates specific abilities on units
func activate_any_abilities(unit, id : int):
	var dictionary_instance = dictionary.new()
	var unit_dictionary = dictionary_instance.unit_scenes[id].instantiate()
	##Anti-tank
	if(unit_ID == 11):
		#Gains a buff if a vehicle is killed by its shot
		if(unit.current_health <= -health_buff):
			self.buff_unit_health(5)
			var anim_player = get_node("AnimationPlayer")
			if(anim_player.is_playing()):
				anim_player.queue("health_bounce")
			else:
				anim_player.play("health_bounce")
			update_label_text()
	##Strider
	if(unit_ID == 24):
		#Gains a buff if a Human is hurt by its shot
		if(unit_dictionary.Human):
			self.buff_unit_damage(4)
			var anim_player = get_node("AnimationPlayer2")
			if(anim_player.is_playing()):
				anim_player.queue("damage_bounce")
			else:
				anim_player.play("damage_bounce")
			update_label_text()
	unit_dictionary.queue_free()
	unit.queue_free()
func check_if_can_buff_unit(unit_dictionary):
	var b = 0
	var can_buff = false
	if(!All):
		while b < buffs_work_against.size():
			if(buffs_work_against[b] != null):
				if(unit_dictionary.get(buffs_work_against[b])):
					can_buff = true
			b += 1
	else:
		can_buff = true
	return can_buff
	
var last_health_change : int = 0
var last_damage_change : int = 0
func buff_unit_health(amount : int):
	health_boost += amount
	last_health_change = amount
	if(amount < 0):
		taken_damage = true
func buff_unit_damage(amount : int):
	damage_boost += amount
	last_damage_change = amount

##Health check called by skill holder at the end of the shop phase once all buffs are done
func health_check():
	if current_health <= 0:
		if(!item_has_transformed):
			get_node("Sprite2D/AnimatedSprite2D").play("death")
		elif(item_has_transformed):
			get_node("Sprite2D/AnimatedSprite2D").play("death_transformed")
		var shop_manager = find_parent("shop_manager")
		shop_manager.tiles_to_delete_units_from.append(self.get_parent())
		self.reparent(shop_manager.find_child("buff_animation_holder"))
		#Leaving stains on the ground
		if(leaves_blood_on_ground):
			play_sound(blood_sound)
			var random_stain = randi_range(0, blood_stain.size()-1)
			var stain = blood_stain[random_stain].instantiate()
			stain.global_position = self.global_position
			find_parent("shop_manager").add_child(stain)
			stain.z_index = 5
		elif(!leaves_blood_on_ground):
			play_sound(explosion_sound)
			var random_stain = randi_range(0, explosion_stain.size()-1)
			var stain = explosion_stain[random_stain].instantiate()
			stain.global_position = self.global_position
			find_parent("shop_manager").add_child(stain)
			stain.z_index = 5
#Controls the heart	
func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if(anim_name == "health_bounce"):
			play_sound(buff_sound)
			#Unit specific abilities that happen on damage gain/loss
			if(unit_name == "Ankylosaurus"):
				if(taken_damage):
					damage_boost += damage_buff
					print(damage_boost + damage_buff)
					update_label_text()
					var anim_player = get_node("AnimationPlayer2")
					if(anim_player.is_playing()):
						anim_player.queue("damage_bounce")
					else:
						anim_player.play("damage_bounce")
			#Play damage animation
			if(last_health_change < 0):
				get_node("item_hurt_anim_player").play("hurt")
				if(last_health_change < 0):
					#SPAWN PARTICLES
					if(particle_effect):
						var particles = particle_effect.instantiate()
						particles.global_position = self.global_position
						find_parent("shop_manager").add_child(particles)
#Controls the sword
func _on_animation_player_2_animation_started(anim_name: StringName) -> void:
	if(anim_name == "damage_bounce"):
		play_sound(buff_sound)
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

##Playing sounds
var buff_sound : AudioStream = preload("res://Sounds/pop.mp3")
var blood_sound : AudioStream  = preload("res://Sounds/blood_die.mp3")
var explosion_sound : AudioStream = preload("res://Sounds/explosion.mp3")
func play_sound(sound_stream: AudioStream):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound_stream

	if player is AudioStreamPlayer2D:
		player.position = self.position

	player.play()

	# Free after it's done playing (based on length of audio)
	await get_tree().create_timer(player.stream.get_length(), false).timeout
	player.queue_free()

#Gets triggered when the unit dies
func _on_animated_sprite_2d_animation_finished() -> void:
	self.queue_free()
