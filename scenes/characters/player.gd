class_name Player
extends CharacterBody2D

@onready var character_sprite : Sprite2D = $CharacterSprite
@onready var animation_player : AnimationPlayer = %AnimationPlayer

enum ControlScheme {CPU, P1, P2}

@export var movement_speed : float = 80.0
@export var control_scheme : ControlScheme

var heading = Vector2.RIGHT

func _physics_process(delta):
	if control_scheme == ControlScheme.CPU:
		pass #AI has its own movement system
	else:
		handle_player_input()
	flip_char_sprite()
	set_heading()

	handle_animations()
	move_and_slide()

func handle_player_input(): 
	var direction = KeyUtils.get_input_vector(control_scheme)
	velocity = direction.normalized() * movement_speed

func handle_animations():
	if velocity.length() > 0:
		animation_player.play("Run")
	else:
		animation_player.play("Idle")

func set_heading():
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func flip_char_sprite():
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
	elif heading == Vector2.LEFT:
		character_sprite.flip_h = true
