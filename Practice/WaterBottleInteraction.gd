extends Area2D

const ITEM_ID = 1

func _ready():
	pass # Replace with function body.

func interact ():
	get_node ("../AnimatedSprite").animation = "empty"
	$CollisionShape2D.disabled = true
	return ITEM_ID
