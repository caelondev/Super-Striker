extends CharacterBody2D

@export var movement_speed : int = 100

func _physics_process(delta):
	handle_input()
	move_and_slide()

func handle_input(): 
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = direction.normalized() * movement_speed
