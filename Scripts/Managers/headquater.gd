extends Node

@export var max_health = 150
var health = 150

var damage_to_do : int

var explosion_stain : PackedScene = preload("res://Prefabs/Effects/Stains/residue/residue_1.tscn")

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
	#Make mark on the ground
	var stain = explosion_stain.instantiate()
	stain.find_child("Sprite2D").scale = stain.find_child("Sprite2D").scale * 3.5
	stain.global_position = find_child("Sprite2D").global_position
	find_parent("combat_manager").add_child(stain)
	queue_free()


func _on_area_2d_mouse_entered() -> void:
	var gm = find_parent("game_manager")
	#Makes sure the game isnt over
	if(gm.game_over_canvas.visible == false):
		var id = gm.base_ID
		var base_name = gm.base_name
		var desc = gm.base_description
		find_parent("combat_manager").find_child("Tooltip").update_base_tooltip(id, base_name, desc)


func set_base_shadow():
	find_child("shadow").change_shadow()
