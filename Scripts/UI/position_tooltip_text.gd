extends Node

@export var offset : float = 3

func _ready():
	update_text()

func update_text():
	var x = 0
	while(x < get_child_count()-1):
		if(get_child(x).visible == true):
			var text_top = get_child(x)
			var text_bottom = get_child(x+1)
			text_bottom.position.y = text_top.position.y + offset + (text_top.get_content_height()*text_top.scale.y)
			text_bottom.position.x = text_top.position.x
		x+=1
	find_parent("Tooltip").find_child("background").update_background()
