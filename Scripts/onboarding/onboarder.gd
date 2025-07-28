extends Node

var unit_tutorial : bool = true
var battle_tutorial : bool = true
var health_tutorial : bool = true
#Onboarding prefabs
var unit_tutorial_prefab : PackedScene = preload("res://Prefabs/tutorials/unit_tutorial.tscn")
var battle_tutorial_prefab : PackedScene = preload("res://Prefabs/tutorials/battle_tutorial.tscn")
var health_tutorial_prefab : PackedScene = preload("res://Prefabs/tutorials/health_tutorial.tscn")

func _ready():
	check_tutorials()

func check_tutorials():
	#If tutorials are disabled, then delete this object
	if(!Settings.tutorials_enabled):
		queue_free()
	elif(Settings.tutorials_enabled):
		if(!Settings.unit_tutorial_completed):
			#Spawn in unit tutorial
			var tutorial = unit_tutorial_prefab.instantiate()
			self.add_child(tutorial)
			tutorial.global_position = find_child("unit_tutorial_pos").global_position
			get_parent().unit_tutorial = tutorial
			Settings.completed_tutorial("unit")
		elif(!Settings.battle_tutorial_completed):
			#Spawn in unit tutorial
			var tutorial = battle_tutorial_prefab.instantiate()
			self.add_child(tutorial)
			tutorial.global_position = find_child("battle_tutorial_pos").global_position
			get_parent().battle_tutorial = tutorial
			Settings.completed_tutorial("battle")
		elif(!Settings.health_tutorial_completed and get_parent().find_parent("game_manager").turn_number == 2):
			#Spawn in unit tutorial
			var tutorial = health_tutorial_prefab.instantiate()
			self.add_child(tutorial)
			tutorial.global_position = find_child("health_tutorial_pos").global_position
			Settings.completed_tutorial("health")
