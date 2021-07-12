extends KinematicBody2D

const speed = 240
const MAX_HP = 10
const MAX_MP = 10
var currentHP = 10
var currentMP = 10

var velocity = Vector2 (0, 0)
var attackStart = false
var attackCooldown = 60
var moveAndAttack = false
var changingShape
var interactiveItem = null

func _ready():
	changingShape = false
	$AnimatedSprite.play ()

func _process(delta):
	if (get_node ("..").getCurrentShape () != "body"):
		return
	updateBars ()
	velocity.y += 20
	if is_on_floor():
		velocity.y = 0
	if (changingShape == true):
		velocity.x = 0
		move_and_slide (velocity, Vector2 (0, -1));
		return
	if (attackCooldown != 0):
		attackCooldown -= 1
	if (Input.is_action_pressed("ui_accept") and attackCooldown == 0):
		attackCooldown = 60
		attackStart = true
		if (velocity.x == 0):
			moveAndAttack = false
		else:
			moveAndAttack = true
	if (Input.is_action_pressed ("ui_down") and (attackStart == false)):
		get_node ("..").changeShapeTo ("plash")
	elif Input.is_action_pressed ("ui_interact") and attackStart == false and interactiveItem != null:
		var itemID = interactiveItem.interact ()
		if itemID == 1:
			if $Bottle.animation == "empty":
				$Bottle.animation = "full"
			elif $Bottle.animation == "full":
				currentMP = MAX_MP
	elif (Input.is_action_pressed ("ui_left") and (moveAndAttack == true or attackStart == false)):
		velocity.x = -speed
	elif (Input.is_action_pressed ("ui_right") and (moveAndAttack == true or attackStart == false)):
		velocity.x = speed
	else:
		velocity.x = 0
	if Input.is_action_pressed ("ui_use_item"):
		if $Bottle.animation == "full":
			$Bottle.animation = "empty"
			currentMP = MAX_MP

	if (attackStart == true):
		$AnimatedSprite.speed_scale = 1.4
		if (moveAndAttack == false):
			$AnimatedSprite.animation = "attack"
		else:
			$AnimatedSprite.animation = "attackOnMove"
	elif (velocity.x == 0):
		$AnimatedSprite.speed_scale = 0.35
		$AnimatedSprite.animation = "stand"
	else:
		$AnimatedSprite.speed_scale = 1
		if (velocity.x < 0):
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk"
	move_and_slide (velocity, Vector2 (0, -1));


func _on_AnimatedSprite_animation_finished():
	if (($AnimatedSprite.animation == "attack") or ($AnimatedSprite.animation == "attackOnMove")):
		attackStart = false
	elif ($AnimatedSprite.animation == "rise"):
		changingShape = false


func _on_AnimatedSprite_frame_changed():
	if ((($AnimatedSprite.animation == "attack") or ($AnimatedSprite.animation == "attackOnMove")) and ($AnimatedSprite.frame == 2) and (currentMP != 0)):
		if ($AnimatedSprite.flip_h == true):
			$BladeNode/BladeArea/AnimatedSprite.flip_h = true
			$BladeNode.position = $AnimatedSprite.position + Vector2 (-256-86, -8)
		else:
			$BladeNode/BladeArea/AnimatedSprite.flip_h = false
			$BladeNode.position = $AnimatedSprite.position + Vector2 (86, -8)
		$BladeNode/BladeArea/AnimatedSprite.frame = 0
		$BladeNode/BladeArea/AnimatedSprite.speed_scale = 4
		$BladeNode/BladeArea/CollisionPolygon2D.disabled = false
		currentMP -= 1
		$BladeNode.show ()

func _on_PlayersHurtbox_was_damaged (damage):
	currentHP -= damage

func _on_PlayersInteractionArea_area_entered (area):
	if area.is_in_group ("interactive"):
		interactiveItem = area

func _on_PlayersInteractionArea_area_exited (area):
	if area.is_in_group ("interactive"):
		interactiveItem = null

func disableAll ():
	$CollisionPolygon2D.disabled = true
	$PlayersHurtbox/CollisionPolygon2D.disabled = true
	$Camera2D.current = false
	hide ()
	
func enableAll ():
	$CollisionPolygon2D.disabled = false
	$PlayersHurtbox/CollisionPolygon2D.disabled = false
	$Camera2D.current = true
	changingShape = true
	show ()

func getGlobalPos ():
	return global_position.x

func getBottleState ():
	if $Bottle.animation == "empty":
		return false
	elif $Bottle.animation == "full":
		return true

func updateBars ():
	$PlayersHPBar.value = currentHP
	$PlayersMPBar.value = currentMP
	if currentHP <= 0:
		get_tree ().change_scene ("res://GameOver.tscn")







