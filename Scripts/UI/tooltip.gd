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
	self.scale = Vector2(0,0)
	background = find_child("background")
	background.position.y = offset
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

var already_flipped : bool = false
var anim_finished : bool = false
func _process(delta: float) -> void:
	if(!self.visible and already_flipped):
		already_flipped = false
	elif(self.global_position.y - background.size.y - offset < 0 and !already_flipped):
		#I HAVE NO IDEA WHY IT NEEDS TO BE /6 BUT IT DOESNT WORK OTHERWISE
		background.position.y = offset/6
		already_flipped = true
	elif(self.global_position.y + background.size.y - offset > get_viewport().get_visible_rect().size.y and !already_flipped):
		already_flipped = true
		background.position.y = -offset


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "tooltip_popout"):
		self.set_visible(false)
