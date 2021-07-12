extends Node2D

var shape = "body"
# shapes: body, plash, ...

func _ready():
	pass

func _process(delta):
	if (Input.is_action_pressed ("ui_page_up") and getCamera (shape).zoom.x < 5):
		getCamera (shape).zoom.x += 0.1
		getCamera (shape).zoom.y += 0.1
	if (Input.is_action_pressed ("ui_page_down") and getCamera (shape).zoom.x > 1):
		getCamera (shape).zoom.x -= 0.1
		getCamera (shape).zoom.y -= 0.1

func getCurrentShape ():
	return shape

func changeShapeTo (nextShape):
	shapesForm (shape).disableAll ()
	shapesForm (nextShape).enableAll ()
	
	getCamera (nextShape).zoom = getCamera (shape).zoom
	getAnimation (nextShape).flip_h = getAnimation (shape).flip_h
	
	var correction = Vector2 (0, 0)
	if (shape == "plash" and nextShape == "body"):
		getAnimation (nextShape).animation = "rise"
		getAnimation (nextShape).speed_scale = 1.5
		correction.y = -1
	shapesForm (nextShape).global_position = shapesForm (shape).global_position + correction
	shape = nextShape

func shapesForm (shape1):
	if (shape1 == "body"):
		return $WizzardBody
	elif (shape1 == "plash"):
		return $WizzardPlash

func getCamera (shape1):
	if (shape1 == "body"):
		return $WizzardBody/Camera2D
	elif (shape1 == "plash"):
		return $WizzardPlash/Camera2D

func getAnimation (shape1):
	if (shape1 == "body"):
		return $WizzardBody/AnimatedSprite
	elif (shape1 == "plash"):
		return $WizzardPlash/AnimatedSprite
