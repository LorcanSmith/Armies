extends Node2D
#Unit dictionary, used to spawn in upgraded units
var dictionary = preload("res://Scripts/Units/dictionary.gd")
#Is the tooltip off the screen? If so it should be flipped
var flipped : bool = false
var background : TextureRect
@export var offset : float

var hide_tooltip : bool = false
@export var time_till_auto_close : float = 0.3
var current_time_till_close

#The ID for the unit whos info we are currently showing
var current_unit_ID
var current_base_ID
#Is the tooltip showing a base or a unit
var currently_showing_unit : bool

var unit_name : RichTextLabel
var description : RichTextLabel
var health : RichTextLabel
var skill_damage : RichTextLabel
var skill_heal : RichTextLabel
var brawl : RichTextLabel
var reload : RichTextLabel
var cost : RichTextLabel
var type : RichTextLabel

func _ready() -> void:
	current_time_till_close = time_till_auto_close
	self.visible = false
	self.scale = Vector2(0,0)
	unit_name = find_child("name")
	description = find_child("description")
	health = find_child("health")
	skill_damage = find_child("skill")
	skill_heal = find_child("heal")
	brawl = find_child("brawl")
	reload = find_child("reload")
	cost = find_child("cost")
	type = find_child("type")

func update_tooltip(u, damage_boost, health_boost) -> void:
	if(u != -1):
		if(u != current_unit_ID or !currently_showing_unit  or self.visible == false):
			#Pop tooltip in if the tooltip is hidden
			if(self.visible == false):
				self.visible = true
				self.get_node("AnimationPlayer").play("tooltip_appear")
			else:
				self.get_node("AnimationPlayer").play("tooltip_refresh")
		currently_showing_unit = true
		current_unit_ID = u
		var dictionary_instance = dictionary.new()
		var unit = dictionary_instance.unit_scenes[u].instantiate()
		var item = dictionary_instance.item_scenes[u].instantiate()
		find_child("heart").visible = true
		find_child("sword").visible = true
		find_child("cross").visible = true
		unit_name.text = unit.name
		description.text = item.description
		health.text = str(unit.max_health + health_boost)
		skill_damage.text = str(unit.skill_damage + damage_boost)
		skill_heal.text = str(unit.skill_heal)
		brawl.text = str("Brawl Damage: ", unit.brawl_damage)
		reload.text = str("Reload Time: ", unit.reload_time)
		cost.text = str("Buy Cost: ", item.buy_cost, " / Sell Cost: ", item.sell_cost)
		var x = 0
		var types = []
		while(x < unit.unit_types.size()):
			#Finds the boolean with the same name as unit_types[x]
			var type = unit.get(unit.unit_types[x])
			if(type):
				types.append(unit.unit_types[x])
			x += 1
		type.text = str("Types: ", ", ".join(types))
	#Resets the time so the tooltip doesn't auto close
	current_time_till_close = time_till_auto_close
	hide_tooltip = false
func update_base_tooltip(id, base_name, desc):
	#Pop tooltip in if the tooltip is hidden
	if(id != current_base_ID or currently_showing_unit or self.visible == false):
		if(self.visible == false):
			self.visible = true
			self.get_node("AnimationPlayer").play("tooltip_appear")
		else:
			self.get_node("AnimationPlayer").play("tooltip_refresh")
	currently_showing_unit = false
	current_base_ID = id
	unit_name.text = base_name
	description.text = desc
	find_child("heart").visible = false
	find_child("sword").visible = false
	find_child("cross").visible = false
	health.text = str("")
	skill_damage.text = str("")
	skill_heal.text = str("")
	brawl.text = str("")
	reload.text = str("")
	cost.text = str("")
	type.text = str("")
	#Resets the time so the tooltip doesn't auto close
	current_time_till_close = time_till_auto_close
	hide_tooltip = false
var anim_finished : bool = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "tooltip_popout"):
		self.visible = false

func _on_close_button_pressed() -> void:
	get_node("AnimationPlayer").play("tooltip_popout")
	#Turn off select button on crates
	var base_crate = find_parent("shop_manager").find_child("base_spawn_location").get_child(0)
	print(base_crate)
	if(base_crate):
		base_crate.find_child("buy_base_button").visible = false

func _process(delta: float) -> void:
	if(self.visible and hide_tooltip):
		current_time_till_close -= delta
		if(current_time_till_close <= 0):
			get_node("AnimationPlayer").play("tooltip_popout")
