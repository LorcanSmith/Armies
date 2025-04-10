extends Node

var coin : PackedScene = preload("res://Prefabs/Effects/UI/coin_effect.tscn")

func item_sold(amount):
	var coins_left = amount
	while coins_left > 0:
		var c = coin.instantiate()
		self.add_child(c)
		c.global_position = self.global_position
		c.global_position.x += randf_range(-10,10)
		c.global_position.y += randf_range(-10,10)
		coins_left -= 1
		await get_tree().create_timer(0.1).timeout
