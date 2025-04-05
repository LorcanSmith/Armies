extends Node2D

func _on_child_entered_tree(node):
	var children =  get_children()
	var counter = children.size()
	while counter > 0:
		counter -= 1
		children[counter].animate()
		children[counter].tween.tween_property(children[counter], "position:y", ((children.size() - counter) - 1) * 20, .1)
