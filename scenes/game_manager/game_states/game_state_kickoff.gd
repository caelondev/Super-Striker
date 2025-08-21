class_name GameStateKickoff
extends GameState

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("continue") or KeyUtils.get_screen_pressed():
		GameEvents.start_kickoff.emit()
		transition_state(GameManager.State.IN_PLAY)
