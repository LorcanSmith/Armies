extends Control
#Unit dictionary, used to spawn in upgraded units
var dictionary = preload("res://Scripts/Units/dictionary.gd")

var unit_name : RichTextLabel
var description : RichTextLabel
var health : RichTextLabel
var skill_damage : RichTextLabel
var skill_heal : RichTextLabel
var brawl : RichTextLabel
var reload : RichTextLabel
var cost : RichTextLabel

func update_tooltip() -> void:
	if(get_parent().unit_ID > -1):
		var dictionary_instance = dictionary.new()
		var unit = dictionary_instance.unit_scenes[get_parent().unit_ID].instantiate()
		var item = dictionary_instance.item_scenes[get_parent().unit_ID].instantiate()
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
