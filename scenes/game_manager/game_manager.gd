extends Node

const DURATION_IMPACT_PAUSE := 200
const DURATION_GAME_SEC := 2 * 60

enum State {IN_PLAY, SCORED, RESET, KICKOFF, OVERTIME, GAMEOVER}

var countries : Array[String] = ["FRANCE", "USA"]
var current_state : GameState = null
var player_setup : Array[String] = ["FRANCE", ""]
var score : Array[int] = [0, 0]
var state_factory := GameStateFactory.new()
var time_left : float
var ready_players := 0
var time_since_last_pause := Time.get_ticks_msec()

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func _ready() -> void:
	time_left = DURATION_GAME_SEC
	GameEvents.impact_received.connect(on_impact_received.bind())
	GameEvents.player_ready.connect(on_player_ready.bind())
	switch_state(State.RESET)

func _physics_process(delta: float) -> void:
	if get_tree().paused and Time.get_ticks_msec() - time_since_last_pause > DURATION_IMPACT_PAUSE:
		get_tree().paused = false

func switch_state(state: State, state_data: GameStateData = GameStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, state_data)
	current_state.state_tranaition_requested.connect(switch_state.bind())
	current_state.name = "GameStateMachine: " + str(state)
	call_deferred("add_child", current_state)

func on_player_ready() -> void:
	ready_players += 1
	if ready_players >= 12:
		GameEvents.ready_for_kickoff.emit()

func is_coop() -> bool:
	return player_setup[0] == player_setup[1]

func is_single_player() -> bool:
	return player_setup[1].is_empty()

func is_game_tied() -> bool:
	return score[0] == score[1]

func get_winner_country() -> String:
	assert(not is_game_tied())
	return countries[0] if score[0] > score[1] else countries[1]

func is_times_up() -> bool:
	return time_left <= 0

func increase_score(country_scored_on: String) -> void:
	var index_country_scoring := 1 if  country_scored_on == countries[0] else 0
	score[index_country_scoring] += 1
	GameEvents.score_changed.emit()

func has_someone_scored() -> bool:
	return score[0] > 0 or score[1] > 0

func on_impact_received(_impact_position: Vector2, is_high_intensity: bool) -> void:
	if is_high_intensity:
		time_since_last_pause = Time.get_ticks_msec()
		get_tree().paused = true
