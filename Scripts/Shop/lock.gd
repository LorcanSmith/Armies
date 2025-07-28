extends Node
var starting_size : float

@export var expanding_amount : float = 1.1

@export var cost : int = 10

var disable_lock : bool = false
func _ready() -> void:
	starting_size = self.scale.x
	find_child("lock_cost").text = str(cost)
	check_slots_left(true)
	

func _on_pressed() -> void:
	#Stops the lock from being clickable during its popout animation
	if(!disable_lock and find_parent("shop_manager").money >= cost):
		find_parent("shop_item_generator").increase_shop_slots()
		get_node("lock_animator").play("unlock_tile")
		check_slots_left(false)
func check_slots_left(start_of_round_check : bool):
	var gm = find_parent("game_manager")
	if(gm.shop_slots == gm.MAX_SHOP_SLOTS):
		if(!start_of_round_check):
			disable_lock = true
			get_node("lock_animator").play("lock_disappear")
		elif(start_of_round_check):
			get_parent().queue_free()
	
func _on_mouse_entered() -> void:
	self.scale = Vector2(starting_size * expanding_amount, starting_size * expanding_amount)

func _on_mouse_exited() -> void:
	self.scale = Vector2(starting_size, starting_size)


func _on_lock_animator_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "lock_disappear"):
		get_parent().queue_free()
