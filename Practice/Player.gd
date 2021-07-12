extends Area2D

const speed = 150
var velocity = Vector2 (0, 0)
var inBlock = false

func _ready():
	$AnimatedSprite.play ()

func _process(delta):
	velocity.y += 10
	if Input.is_action_pressed ("ui_left"):
		velocity.x = -speed
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed
	else:
		velocity.x = 0
	if (velocity.x == 0):
		$AnimatedSprite.speed_scale = 0.35
		$AnimatedSprite.animation = "stand"
	else:
		$AnimatedSprite.speed_scale = 0.7
		if (velocity.x < 0):
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk"
	if (inBlock == false):
		position += velocity * delta


func _on_Area2D_body_entered(body):
	if (body.name == "TileMap"):
		inBlock = true


func _on_Area2D_body_exited(body):
	if (body.name == "TileMap"):
		inBlock = false
