extends Node2D

var damage = 7

func _ready():
	$BladeArea/AnimatedSprite.play ()

func _on_AnimatedSprite_animation_finished():
	$BladeArea/CollisionPolygon2D.disabled = true
	hide ()

func _on_BladeArea_area_entered (area):
	if area.is_in_group ("hurtbox") and area.name != "PlayersHurtbox":
		area.emit_signal ("was_damaged", damage)
