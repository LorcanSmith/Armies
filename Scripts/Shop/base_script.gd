extends Node2D

var disabled : bool = false
@export var base_id : int = -1

@export var description : String
var tooltip : Node2D
@export var show_tooltip_time : float = 1.4
var current_time_till_tooltip : float

var base_manager : Node2D

#Keeps track if the player has bought the base yet. Stops the user from being able to
#pick up a bought base
var bought : bool = false

#The child sprite which is the visuals for the item
var sprite : Sprite2D


#item scale
var item_hovered_scale = 1.2
var item_clicked_scale = 1.4

func _ready() -> void:
	sprite = find_child("Sprite2D")
	base_manager = find_parent("Camera2D").find_child("base_manager")
	find_child("set_base_UI").global_position = find_parent("Camera2D").global_position

func _on_set_base_pressed() -> void:
	base_manager.set_base(base_id)
	#Delete the crate
	find_parent("base_crate").queue_free()


func _on_base_button_pressed() -> void:
	find_child("set_base_UI").visible = true
	find_parent("UI").find_child("crate").visible = false

func _on_close_button_pressed() -> void:
	find_child("set_base_UI").visible = false
	find_parent("UI").find_child("crate").visible = true
