class_name GameStateScored
extends GameState

const DURATION_CELEBRATION := 3000

var time_since_laat_celebration := Time.get_ticks_msec()

func _enter_tree() -> void:
	manager.increase_score(state_data.country_scored_on)

func _physics_process(delta: float) -> void:
	if Time.get_ticks_msec() - time_since_laat_celebration > DURATION_CELEBRATION:
		transition_state(GameManager.State.RESET, state_data)
