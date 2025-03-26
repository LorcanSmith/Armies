extends Node2D
#Unit dictionary, used to spawn in upgraded units
var dictionary = preload("res://Scripts/Units/dictionary.gd")
#Is the tooltip off the screen? If so it should be flipped
var flipped : bool = false
var background : TextureRect
@export var offset : float

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

func update_tooltip(u) -> void:
	if(u != -1):
		var dictionary_instance = dictionary.new()
		var unit = dictionary_instance.unit_scenes[u].instantiate()
		var item = dictionary_instance.item_scenes[u].instantiate()
		unit_name = find_child("name")
		description = find_child("description")
		health = find_child("health")
		skill_damage = find_child("skill")
		skill_heal = find_child("heal")
		brawl = find_child("brawl")
		reload = find_child("reload")
		cost = find_child("cost")
		unit_name.text = unit.name
		description.text = item.description
		health.text = str("Health: ", unit.max_health)
		skill_damage.text = str("Skill Damage: ", unit.skill_damage)
		skill_heal.text = str("Skill Heal: ", unit.skill_heal)
		brawl.text = str("Brawl Damage: ", unit.brawl_damage)
		reload.text = str("Reload Time: ", unit.reload_time)
		cost.text = str("Buy Cost: ", item.buy_cost, " / Sell Cost: ", item.sell_cost)

var anim_finished : bool = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "tooltip_popout"):
		#self.set_visible(false)
		pass
