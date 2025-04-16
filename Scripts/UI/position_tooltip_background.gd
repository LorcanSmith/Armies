extends Node

var offset : float = 20

func _ready() -> void:
	update_background()

func update_background():
	get_parent().position = Vector2(0,0)
	var x = 0
	while(x < get_child_count()-1):
		var texture_top = get_child(x)
		var texture_bottom = get_child(x+1)
		if(x == 1):
			var label = find_parent("Tooltip").find_child("type")
			var label_bottom_y = label.position.y + (label.get_content_height() * label.scale.y)
			var new_height = label_bottom_y - texture_top.position.y
			texture_top.size.y = new_height

		texture_bottom.position.y = texture_top.position.y + texture_top.size.y
		texture_bottom.position.x = texture_top.position.x
		x+=1
		
func _process(delta: float) -> void:
	var last_texture = get_child(get_child_count() - 1)

	var viewport_rect = get_viewport().get_visible_rect()
	var screen_bottom = viewport_rect.size.y

	while((last_texture.global_position.y + last_texture.size.y + offset) > screen_bottom):
		get_parent().position.y -= 5
