class_name GameStateReset
extends GameState

func _enter_tree() -> void:
	GameEvents.ready_for_kickoff.connect(on_kickoff_ready.bind())
	GameEvents.team_reset.emit()

func on_kickoff_ready() -> void:
	transition_state(GameManager.State.KICKOFF, state_data)
