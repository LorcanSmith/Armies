extends Node2D
#Unit dictionary, used to spawn in upgraded units
var dictionary = preload("res://Scripts/Units/dictionary.gd")
#Is the tooltip off the screen? If so it should be flipped
var flipped : bool = false
var background : TextureRect
@export var offset : float

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

func _ready() -> void:
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

func update_tooltip(u, damage_boost, health_boost) -> void:
	if(u != -1):
		if(u != current_unit_ID or !currently_showing_unit):
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
		unit_name.text = unit.name
		description.text = item.description
		health.text = str("Health: ", unit.max_health + health_boost)
		skill_damage.text = str("Skill Damage: ", unit.skill_damage + damage_boost)
		skill_heal.text = str("Skill Heal: ", unit.skill_heal)
		brawl.text = str("Brawl Damage: ", unit.brawl_damage)
		reload.text = str("Reload Time: ", unit.reload_time)
		cost.text = str("Buy Cost: ", item.buy_cost, " / Sell Cost: ", item.sell_cost)

func update_base_tooltip(id, base_name, desc):
	#Pop tooltip in if the tooltip is hidden
	if(id != current_base_ID or currently_showing_unit):
		if(self.visible == false):
			self.visible = true
			self.get_node("AnimationPlayer").play("tooltip_appear")
		else:
			self.get_node("AnimationPlayer").play("tooltip_refresh")
	currently_showing_unit = false
	current_base_ID = id
	unit_name.text = base_name
	description.text = desc
	health.text = str("")
	skill_damage.text = str("")
	skill_heal.text = str("")
	brawl.text = str("")
	reload.text = str("")
	cost.text = str("")
	

var anim_finished : bool = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "tooltip_popout"):
		self.visible = false


func _on_button_pressed() -> void:
	get_node("AnimationPlayer").play("tooltip_popout")
