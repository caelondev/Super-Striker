class_name PlayerStateHurt
extends PlayerState

const FRICTION_AIR := 35.0
const STATE_DURATION := 1000
const HURT_HEIGHT_VELOCITY := 2
const BALL_TUMBLE_SPEED := 20

var time_since_hurt := Time.get_ticks_msec()

func _enter_tree() -> void:
	animation_player.play("Hurt")
	player.height_velocity = HURT_HEIGHT_VELOCITY
	player.height = 0.1
	if ball.carrier == player:
		ball.tumble(player_state_data.hurt_direction * BALL_TUMBLE_SPEED)
		GameEvents.impact_received.emit(player.global_position, false)

func _physics_process(delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * FRICTION_AIR)
	if Time.get_ticks_msec() - time_since_hurt > STATE_DURATION:
		transition_state(Player.State.RECOVERING)
