extends CharacterBody2D


const SPEED = 200.0
@onready var animated_sprite = $AnimationsChar

func _physics_process(delta):
	var direction : Vector2 = Input.get_vector( "ui_left","ui_right", "ui_up","ui_down")
	if direction:
		animated_sprite.play('run')
		if direction[0] > 0:
			animated_sprite.flip_h = false
		if direction[0] < 0:
			animated_sprite.flip_h = true
	else:
		animated_sprite.play('idle')
	velocity = direction * SPEED

	move_and_slide()
