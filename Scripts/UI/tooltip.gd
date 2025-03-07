extends Control
#Unit dictionary, used to spawn in upgraded units
var dictionary = preload("res://Scripts/Units/dictionary.gd")

@export var image_used : bool
@export var image : Sprite2D

var description : RichTextLabel
var health : RichTextLabel
var skill_damage : RichTextLabel
var skill_heal : RichTextLabel
var brawl : RichTextLabel
var cost : RichTextLabel

func _ready() -> void:
	var dictionary_instance = dictionary.new()
	var unit = dictionary_instance.unit_scenes[get_parent().unit_ID].instantiate()
	var item = dictionary_instance.item_scenes[get_parent().unit_ID].instantiate()
	description = find_child("description")
	health = find_child("health")
	skill_damage = find_child("skill")
	skill_heal = find_child("heal")
	brawl = find_child("brawl")
	cost = find_child("cost")
	description.text = item.description
	health.text = str(unit.max_health)
	skill_damage.text = str(unit.skill_damage)
	skill_heal.text = str(unit.skill_heal)
	brawl.text = str(unit.brawl_damage)
	cost.text = str(item.buy_cost)
