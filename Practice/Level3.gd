extends Node

func _ready():
	$Wizzard/WizzardBody.currentHP = GlobalVariables.currentHP
	$Wizzard/WizzardBody.currentMP = GlobalVariables.currentMP
	if GlobalVariables.hasBottle == true:
		$Wizzard/WizzardBody/Bottle.animation = "full"
	else:
		$Wizzard/WizzardBody/Bottle.animation = "empty"

func _process(delta):
	if (Input.is_action_pressed ("ui_ctrl_pressed")):
		get_tree ().call_group ("enemy", "turn_line_of_sight", true)
	else:
		get_tree ().call_group ("enemy", "turn_line_of_sight", false)
