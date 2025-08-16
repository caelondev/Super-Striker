class_name PlayerStateVolleyKick
extends PlayerState

const BALL_HEIGHT_MIN := 5
const BALL_HEIGHT_MAX := 50
const BONUS_POWER := 1.5

func _enter_tree():
	animation_player.play("VolleyKick")
	ball_detection_area.body_entered.connect(on_ball_enter.bind())

func animation_complete() -> void:
	transition_state(Player.State.RECOVERING)

func on_ball_enter(context_ball: Ball) -> void:
	if context_ball.can_air_connect(BALL_HEIGHT_MIN, BALL_HEIGHT_MAX):
		var destination = (target_goal.get_random_target_position() - ball.global_position).normalized()
		ball.shoot(destination * player.power * BONUS_POWER)
