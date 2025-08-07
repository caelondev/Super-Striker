class_name PlayerStateShooting
extends PlayerState

func _enter_tree():
	animation_player.play("Kick")

func animation_complete() -> void:
	if player.control_scheme == Player.ControlScheme.CPU:
		transition_state(Player.State.RECOVERING)
	else:
		transition_state(Player.State.MOVING)
	shoot_ball()

func shoot_ball() -> void:
	ball.shoot(player_state_data.shot_direction * player_state_data.shot_power)
	print(player_state_data)
