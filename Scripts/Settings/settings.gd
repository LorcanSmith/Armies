extends Node

var volume : float = -80


func change_volume(percent: float):

	if(percent <= 0):
		volume = -80
	else:
		volume = lerp(-80, 50, percent / 100.0)
