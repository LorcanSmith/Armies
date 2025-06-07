extends Node

@export var max_health = 150
var health = 150

var damage_to_do : int

func _ready():
	health = max_health
	update_label()

#Does damage and heals headquaters
#Positive numbers to hurt, negative numbers to heal
var dead = false
func hurt(amount : int):
	if(!dead):
		damage_to_do += amount

func projectile_hit(amount : int):
	if(!dead):
		health -= amount
		update_label()
		if(health <= 0):
			dead = true
			destroy_headquarters()
		damage_to_do = 0
		
func update_label():
	find_child("Label").text = str(health) + "/" + str(max_health)
	
#Called when the headquater runs out of health
func destroy_headquarters():
	queue_free()


func _on_area_2d_mouse_entered() -> void:
	var gm = find_parent("game_manager")
	var id = gm.base_ID
	var base_name = gm.base_name
	var desc = gm.base_description
	find_parent("combat_manager").find_child("Tooltip").update_base_tooltip(id, base_name, desc)
