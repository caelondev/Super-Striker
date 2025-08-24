class_name GameStateInPlay
extends GameState

func _enter_tree() -> void:
	GameEvents.team_scored.connect(on_team_scored.bind())

func _physics_process(delta: float) -> void:
	manager.time_left -= delta
	if manager.is_times_up():
		if manager.current_match.is_tied():
			transition_state(GameManager.State.OVERTIME)
		else:
			transition_state(GameManager.State.GAMEOVER)

func on_team_scored(country_scored_on: String) -> void:
	var data = GameStateData.build().set_country_scored_on(country_scored_on)
	transition_state(GameManager.State.SCORED, data)

func show_mobile_ui() -> bool:
	return true
