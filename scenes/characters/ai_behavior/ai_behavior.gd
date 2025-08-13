class_name AIBehavior
extends Node

const AI_TICK_FREQUENCY := 200

var ball : Ball = null
var player : Player = null
var time_since_last_tick := Time.get_ticks_msec() + randi_range(0, AI_TICK_FREQUENCY)

func setup(c_player: Player, c_ball: Ball) -> void:
	player = c_player
	ball = c_ball
func process_ai() -> void:
	if Time.get_ticks_msec() - time_since_last_tick < AI_TICK_FREQUENCY:
		return
	time_since_last_tick = Time.get_ticks_msec()
	perform_ai_movement()
	perform_ai_decisions()

func perform_ai_movement() -> void:
	var total_stear_force := Vector2.ZERO
	total_stear_force += get_duty_stear_force()
	total_stear_force = total_stear_force.limit_length(1.0)
	player.velocity = total_stear_force * player.movement_speed

func perform_ai_decisions() -> void:
	pass

func get_duty_stear_force() -> Vector2:
	return player.weight_on_duty_stearing * player.global_position.direction_to(ball.global_position)
