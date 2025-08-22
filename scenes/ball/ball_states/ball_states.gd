class_name BallState
extends Node

const GRAVITY := 10.0

signal state_transition_requested(new_state: Ball.State)

var animation_player : AnimationPlayer = null
var ball : Ball = null
var ball_sprite : Sprite2D = null
var carrier : Player = null
var player_detection_area : Area2D = null
var state_data : BallStateData = null

func setup(context_ball: Ball, context_player_detection_area : Area2D, context_carrier : Player, context_animation_player : AnimationPlayer, context_ball_sprite: Sprite2D, ball_state_data: BallStateData) -> void:
	ball = context_ball
	player_detection_area = context_player_detection_area
	carrier = context_carrier
	animation_player = context_animation_player
	ball_sprite = context_ball_sprite
	state_data = ball_state_data

func transition_state(ball_state: Ball.State, data: BallStateData = BallStateData.new()):
	state_transition_requested.emit(ball_state, data)

func handle_animation() -> void:
	if ball.velocity.x < 0:
		animation_player.play("Roll")
		animation_player.advance(0)
	elif ball.velocity.x > 0:
		animation_player.play("Roll")
		animation_player.advance(0)
	else:
		animation_player.play_backwards("Idle")
	
func process_gravity(delta: float, bounciness: float = 0.0) -> void:
	if ball.height > 0 or ball.height_velocity > 0:
		ball.height_velocity -= GRAVITY * delta
		ball.height += ball.height_velocity
		if ball.height <= 0:
			ball.height = 0
			if bounciness > 0 and ball.height_velocity < 0:
				ball.height_velocity = -ball.height_velocity * bounciness
				ball.velocity *= bounciness

func move_and_bounce(delta: float) -> void:
	var collider = ball.move_and_collide(ball.velocity * delta)
	if collider != null:
		ball.velocity = ball.velocity.bounce(collider.get_normal()) * ball.BOUNCINESS
		ball.switch_state(Ball.State.FREEFORM)

func can_air_interact() -> bool:
	return false

func can_summon_shot_particle() -> bool:
	return false
