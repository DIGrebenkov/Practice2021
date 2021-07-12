extends Area2D

func _ready():
	pass # Replace with function body.

func interact ():
	GlobalVariables.save_wizzard (get_tree ().current_scene.get_node ("./Wizzard/WizzardBody"))
	get_tree ().change_scene ("res://Level1.tscn")
