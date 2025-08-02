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
	
	if player.velocity != Vector2.ZERO and KeyUtils.get_actions_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		state_transition_requested.emit(Player.State.TACKLING)
