class_name Player
extends CharacterBody2D

enum ControlScheme {CPU, P1, P2}
enum State {MOVING, TACKLE}

@onready var character_sprite : Sprite2D = $CharacterSprite
@onready var animation_player : AnimationPlayer = %AnimationPlayer

@export var movement_speed : float = 80.0
@export var control_scheme : ControlScheme

var heading = Vector2.RIGHT

func _physics_process(delta) -> void:
	flip_char_sprite()
	move_and_slide()

func handle_player_input() -> void: 
	var direction = KeyUtils.get_input_vector(control_scheme)
	velocity = direction.normalized() * movement_speed

func handle_animations() -> void:
	if velocity.length() > 0:
		animation_player.play("Run")
	else:
		animation_player.play("Idle")

func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func flip_char_sprite() -> void:
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
	elif heading == Vector2.LEFT:
		character_sprite.flip_h = true
