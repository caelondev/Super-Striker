class_name PlayerStateMoving
extends PlayerState

func _process(_delta) -> void:
	if player.control_scheme == Player.ControlScheme.CPU:
		pass #AI has its own movement system
	else:
		handle_player_input()
	player.handle_animations()
	player.set_heading()

func handle_player_input() -> void: 
	var direction = KeyUtils.get_input_vector(player.control_scheme)
	player.velocity = direction.normalized() * player.movement_speed
	if player.velocity != Vector2.ZERO:
		teammate_detection_area.rotation = player.velocity.angle()
	
	if player.is_carrying_ball() and KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT) and ball != null:
		transition_state(Player.State.PREP_SHOT)
	elif player.is_carrying_ball() and KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.PASS) and ball != null:
		transition_state(Player.State.PASSING)
	elif player.velocity != Vector2.ZERO and KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		transition_state(Player.State.TACKLING)
