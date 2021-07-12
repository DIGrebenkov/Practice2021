extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact ():
	GlobalVariables.save_wizzard (get_tree ().current_scene.get_node ("./Wizzard/WizzardBody"))
	get_tree ().change_scene ("res://Level3.tscn")
