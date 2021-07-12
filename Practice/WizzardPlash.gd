extends KinematicBody2D

var velocity = Vector2 (0, 0)

var changingShape

func _ready():
	changingShape = true

func _process(delta):
	if (get_node ("..").getCurrentShape () != "plash"):
		return
	velocity.y += 20
	velocity.x = 0
	if (Input.is_action_pressed ("ui_up") and changingShape != true):
		get_node ("..").changeShapeTo ("body")
	if is_on_floor():
		velocity.y = 0
	move_and_slide (velocity, Vector2 (0, -1));

func disableAll ():
	$CollisionShape2D.disabled = true
	$Camera2D.current = false
	hide ()
	
func enableAll ():
	$CollisionShape2D.disabled = false
	$Camera2D.current = true
	changingShape = true
	$AnimatedSprite.animation = "dip"
	$AnimatedSprite.speed_scale = 1.5
	$AnimatedSprite.play ()
	show ()

func _on_AnimatedSprite_animation_finished():
	if ($AnimatedSprite.animation == "dip"):
		$AnimatedSprite.animation = "lie"
		$AnimatedSprite.speed_scale = 0.35
		changingShape = false
