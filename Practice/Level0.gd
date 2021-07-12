extends Node

func _ready():
	$Wizzard/WizzardBody.currentHP = 10
	$Wizzard/WizzardBody.currentMP = 0
	$Wizzard/WizzardBody/Bottle.animation = "empty"
