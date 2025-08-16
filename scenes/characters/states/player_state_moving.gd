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
	
	if player.is_carrying_ball():
		if KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT) and ball != null:
			transition_state(Player.State.PREP_SHOT)
		elif KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.PASS) and ball != null:
			transition_state(Player.State.PASSING)
	elif KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		if ball.can_air_interact():
			if player.velocity == Vector2.ZERO:
				if player.is_facing_target_goal():
					transition_state(Player.State.VOLLEY_KICK)
				else: 
					transition_state(Player.State.BICYCLE_KICK)
			else:
				player.switch_state(Player.State.HEADER)
		elif player.velocity != Vector2.ZERO:
			transition_state(Player.State.TACKLING)
