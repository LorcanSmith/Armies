extends Node

func _ready() -> void:
	check_slots_left()

func _on_pressed() -> void:
	find_parent("shop_item_generator").increase_shop_slots()
	check_slots_left()
func check_slots_left():
	var gm = find_parent("game_manager")
	if(gm.shop_slots == gm.MAX_SHOP_SLOTS):
		queue_free()
