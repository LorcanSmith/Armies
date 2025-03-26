extends Node

#Keeps track of if a unit is currently on the tile
var is_empty : bool = true
#Keeps track of the unit which is currently on the tile
var units_on_tile : Array = []
var brawl : Node2D
var brawl_started = false
var brawl_ended = false

func _ready():
	brawl = find_child("brawl_sprite")

func _process(delta):
	if brawl != null:
		if units_on_tile.size() == 2:
			if !brawl_started:
				get_node("AnimationPlayer").play("fade_in")
				brawl_started = true
			brawl_ended = false
		else:
			if brawl_started:
				if !brawl_ended:
					get_node("AnimationPlayer").play("fade_out")
					brawl_ended = true
				brawl_started = false
		
func unit_placed_on(unit):
	if(!units_on_tile.has(unit)):
		units_on_tile.append(unit)
	is_empty = false



func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.is_in_group("tilemap")):
		area.get_parent().visiblity(false)
