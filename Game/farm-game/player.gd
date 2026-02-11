extends CharacterBody2D

const SPEED = 500.0
@export var money = 0
func _physics_process(delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")

	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
