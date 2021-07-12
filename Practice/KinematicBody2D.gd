extends KinematicBody2D

# constants:
const BASIC_SPEED = 80
const MAX_HP = 10
const BASIC_DAMAGE = 3

const PATROL_RANGE = 384
const SEARCH_RANGE = 1024
const POINT_POS_MODIFIER = 40
const PLAYER_POS_MODIFIER = 150

# statuses:
# 0 - disabled
# 1 - patrols
# 2 - playerDiscovered
# 3 - playerLost
# 4 - isAttacking
var status

# variables:
var velocity = Vector2 (0, 0)

var initialPosition
var playerLastSeenAt
var playerPosition
var speed
var targetPosModifier
var acceleration = 0

var currentHP = 10

# flags
var statusInitialized = false
var destinationReached = false
var turnedLeft = false

func _ready ():
	initialPosition = global_position.x
	updateStatus (1)
	$AnimatedSprite.play ()

func _process (delta):
	# health and mana check
	updateBars ()
	
	# applying gravity
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y += 20
	
	# status check:
	# disabled
	if (status == 0):
		if statusInitialized == false:
			wasDisabled ()
		# only gravity
		velocity.y += 80
		if velocity.x != 0:
			if velocity.x > 0:
				velocity.x -= 1.5
			else:
				velocity.x += 1.5
		elif is_on_floor ():
			velocity.y = 0
		move_and_slide (velocity, Vector2 (0, -1))
		return
	# patrols
	elif (status == 1):
		if statusInitialized == false:
			patrolStart ()
		patrolInProgress ()
	# in chase
	elif (status == 2):
		if statusInitialized == false:
			chaseStart ()
		chaseInProgress ()
	# looking for player
	elif (status == 3):
		if statusInitialized == false:
			searchStart ()
		searchInProgress ()
	# attacking
	elif (status == 4):
		if statusInitialized == false:
			attackStart ()
		return
	
	if global_position.x <= route.getTarget () - targetPosModifier:
		velocity.x = speed
		turnedLeft = false
	elif global_position.x >= route.getTarget () + targetPosModifier:
		velocity.x = -speed
		turnedLeft = true
	else:
		destinationReached = true
		return
	# if velocity changed sign, rotate person
	if turnedLeft != $AnimatedSprite.flip_h:
		turnBack ()
	
	var previousPositionX = global_position.x
	move_and_slide (velocity, Vector2 (0, -1))
	if abs (previousPositionX - global_position.x) < 0.5:
		route.modifyRoute (GlobalVariables.BASIC_ROUTE_MODIFIER)

func _on_Sight_body_entered (body):
	if (body.name == "WizzardBody"):
		playerPosition = body
		playerLastSeenAt = body.getGlobalPos ()
		updateStatus (2)

func _on_Sight_body_exited (body):
	if body.name == "WizzardBody" and status != 4:
		playerLastSeenAt = body.getGlobalPos ()
		updateStatus (3)

func _on_E1Hitbox_area_entered (area):
	if area.is_in_group ("hurtbox") and !area.get_parent ().is_in_group ("enemy"):
		area.emit_signal ("was_damaged", BASIC_DAMAGE)

func _on_E1Hurtbox_was_damaged (damage):
	currentHP -= damage
	# if being backstabbed, turn back
	if status == 1 or status == 3:
		if (turnedLeft == false):
			playerLastSeenAt = global_position.x - POINT_POS_MODIFIER
		else:
			playerLastSeenAt = global_position.x + POINT_POS_MODIFIER
		updateStatus (3)

func _on_AnimatedSprite_frame_changed():
	if ($AnimatedSprite.animation == "attack"):
		if $AnimatedSprite.frame == 4:
			$E1Hitbox/CollisionPolygon2D.disabled = false
		elif $AnimatedSprite.frame == 5:
			$E1Hitbox/CollisionPolygon2D.disabled = true

func _on_AnimatedSprite_animation_finished():
	if ($AnimatedSprite.animation == "attack"):
		updateStatus (3)
		$Sight/CollisionShape2D.disabled = false

func updateBars ():
	$PlayersHPBar.value = currentHP
	if currentHP == MAX_HP:
		$PlayersHPBar.hide ()
	elif currentHP <= 0:
		if status != 0:
			updateStatus (0)
		$PlayersHPBar.hide ()
	else:
		$PlayersHPBar.show ()

func updateStatus (nextStatus):
	statusInitialized = false
	status = nextStatus

func wasDisabled ():
	statusInitialized = true
	if playerLastSeenAt <= global_position.x:
		velocity.x = BASIC_SPEED * 2
	else:
		velocity.x = -BASIC_SPEED * 2
	$AnimatedSprite.animation = "disabled"
	$AnimatedSprite.speed_scale = 0
	$Sight/CollisionShape2D.disabled = true
	$Sight.hide ()
	$E1Hurtbox/CollisionPolygon2D.disabled = true
	$E1Hitbox/CollisionPolygon2D.disabled = true
	set_collision_layer_bit (0, false)
	set_collision_layer_bit (4, true)
	z_index = -1

var rangeModifier
var route = GlobalVariables.routeClass.new ()

func patrolStart ():
	statusInitialized = true
	rangeModifier = PATROL_RANGE
	route.clearRoute ()
	route.addPoint (initialPosition)
	route.addPoint (initialPosition - rangeModifier)
	route.addPoint (initialPosition + rangeModifier)
	route.looped = true
	targetPosModifier = POINT_POS_MODIFIER
	speed = BASIC_SPEED
	$AnimatedSprite.animation = "walk"
	$AnimatedSprite.frame = 0
	$AnimatedSprite.speed_scale = 0.6

func patrolInProgress ():
	if (destinationReached == true):
		destinationReached = false
		route.nextPoint ()

func chaseStart ():
	statusInitialized = true
	route.clearRoute ()
	route.addPoint (playerLastSeenAt)
	targetPosModifier = PLAYER_POS_MODIFIER
	speed = BASIC_SPEED * 2
	$AnimatedSprite.animation = "walk"
	$AnimatedSprite.frame = 0
	$AnimatedSprite.speed_scale = 1.2 ################################### ???

func chaseInProgress ():
	if (destinationReached == true):
		updateStatus (4)
	else:
		playerLastSeenAt = playerPosition.getGlobalPos ()
		route.updateCurrentPoint (playerLastSeenAt)

func searchStart ():
	statusInitialized = true
	rangeModifier = SEARCH_RANGE
	route.clearRoute ()
	route.addPoint (playerLastSeenAt)
	if (global_position.x <= playerLastSeenAt):
		route.addPoint (playerLastSeenAt + rangeModifier)
		route.addPoint (playerLastSeenAt - rangeModifier)
	else:
		route.addPoint (playerLastSeenAt - rangeModifier)
		route.addPoint (playerLastSeenAt + rangeModifier)
	route.addPoint (playerLastSeenAt)
	targetPosModifier = POINT_POS_MODIFIER
	speed = BASIC_SPEED * 1.5
	$AnimatedSprite.animation = "walk"
	$AnimatedSprite.frame = 0
	$AnimatedSprite.speed_scale = 0.8

func searchInProgress ():
	if (destinationReached == true):
		destinationReached = false
		if route.nextPoint () == false:
			updateStatus (1)

func attackStart ():
	statusInitialized = true
	if playerLastSeenAt <= global_position.x and $AnimatedSprite.flip_h == false:
		turnBack ()
	elif playerLastSeenAt >= global_position.x and $AnimatedSprite.flip_h == true:
		turnBack ()
	$AnimatedSprite.animation = "attack"
	$AnimatedSprite.frame = 0
	$AnimatedSprite.speed_scale = 1.4
	$Sight/CollisionShape2D.disabled = true

func turnBack ():
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	$Sight/CollisionShape2D.position.x *= -1
	################################################################# ??
	$Sight/TileMap.position.x *= -1
	####################################################################
	for i in range ($E1Hitbox/CollisionPolygon2D.polygon.size ()):
		$E1Hitbox/CollisionPolygon2D.polygon [i].x *= -1

func turn_line_of_sight (on):
	if on == true:
		$Sight/TileMap.show ()
	else:
		$Sight/TileMap.hide ()



















