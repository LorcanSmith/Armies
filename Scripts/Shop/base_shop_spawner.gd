extends Node

var base_crate : PackedScene = preload("res://Prefabs/Shop Items/Bases/base_crate.tscn")

func _ready() -> void:
	spawn_base_crate()

func spawn_base_crate():
	var instance = base_crate.instantiate()
	add_child(instance)
	instance.position = Vector2(0,0)
