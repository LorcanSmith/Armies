extends Node

var current_base_ID : int = -1
var base_sprite

var base_sprites : Array = [
	preload("res://Sprites/Bases/castle.png"),
	preload("res://Sprites/Bases/bank.png")
]

func _ready() -> void:
	base_sprite = find_child("base_sprite")
func set_base(id):
	current_base_ID = id
	base_sprite.texture = base_sprites[id]
	base_sprite.get_child(0).texture = base_sprites[id]
	
func start_of_turn():
	pass

func end_of_turn():
	pass
	
	
