class_name PlayerStateMoving
extends PlayerState

func _process(delta) -> void:
	if player.control_scheme == Player.ControlScheme.CPU:
		ai_behavior.process_ai()
	else:
		handle_player_input()
	player.handle_animations()
	player.set_heading()

func handle_player_input() -> void: 
	var direction = KeyUtils.get_input_vector(player.control_scheme)
	player.velocity = direction.normalized() * player.movement_speed
	
	if KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		if player.is_carrying_ball() and ball != null:
			transition_state(Player.State.PREP_SHOT)
		elif ball.can_air_interact():
			if player.velocity == Vector2.ZERO:
				if player.is_facing_target_goal():
					transition_state(Player.State.VOLLEY_KICK)
				else:
					transition_state(Player.State.BICYCLE_KICK)
			else:
				player.switch_state(Player.State.HEADER)
		elif player.velocity != Vector2.ZERO:
			transition_state(Player.State.TACKLING)
	
	elif KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.PASS):
		if player.is_carrying_ball() and ball != null:
			transition_state(Player.State.PASSING)
		elif can_teammate_pass_ball():
			ball.carrier.send_pass_request(player)
	
	elif KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.SWAP):
		player.swap_control_scheme_request.emit(player)

func can_pass() -> bool:
	return true

func can_carry_ball() -> bool:
	return player.role != Player.Role.GOALIE

func can_teammate_pass_ball() -> bool:
	return ball.carrier != null and ball.carrier.control_scheme == Player.ControlScheme.CPU and ball.carrier.country == player.country
