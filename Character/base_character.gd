extends CharacterBody2D


const SPEED = 300.0

func _physics_process(delta):
	var direction : Vector2 = Input.get_vector( "ui_left","ui_right", "ui_up","ui_down")
	velocity = direction * SPEED

	move_and_slide()
