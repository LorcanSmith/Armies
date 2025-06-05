extends Node2D

var disabled : bool = false
@export var base_id : int = -1
@export var base_name : String
@export var description : String
@export var start_of_shop_desc : String
@export var before_combat_desc : String
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
	find_child("Description").text = description


func _on_base_button_pressed() -> void:
	if(find_parent("base_crate") != null):
		find_parent("base_crate").set_current_base(self)
	else:
		find_parent("shop_item_generator").set_current_base(self)
func _on_close_button_pressed() -> void:
	find_child("set_base_UI").visible = false
	find_parent("UI").find_child("crate").visible = true
	get_node("AnimationPlayer").play("base_confirm_disappear")
	find_parent("base_crate").get_node("AnimationPlayer").play("crate_appear")
	find_parent("base_crate").hide_base_options(true)


func _on_select_base_button_mouse_entered() -> void:
	#Set the tooltip
	find_parent("shop_manager").find_child("Tooltip").update_base_tooltip(base_id,base_name, description)
	
