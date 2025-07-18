extends Node
var starting_size : float

@export var expanding_amount : float = 1.1
func _ready() -> void:
	starting_size = self.scale.x
	check_slots_left()

func _on_pressed() -> void:
	find_parent("shop_item_generator").increase_shop_slots()
	check_slots_left()
func check_slots_left():
	var gm = find_parent("game_manager")
	if(gm.shop_slots == gm.MAX_SHOP_SLOTS):
		queue_free()

func _on_mouse_entered() -> void:
	self.scale = Vector2(starting_size * expanding_amount, starting_size * expanding_amount)

func _on_mouse_exited() -> void:
	self.scale = Vector2(starting_size, starting_size)
