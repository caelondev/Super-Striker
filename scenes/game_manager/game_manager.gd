extends Node

const DURATION_GAME_SEC := 2 * 60

enum State {IN_PLAY, SCORED, RESET, KICKOFF, OVERTIME, GAMEOVER}

var countries : Array[String] = ["FRANCE", "USA"]
var current_state : GameState = null
var score := [0, 0]
var state_factory := GameStateFactory.new()
var time_left : float
var ready_players := 0

func _ready() -> void:
	time_left = DURATION_GAME_SEC
	GameEvents.player_ready.connect(on_player_ready.bind())
	switch_state(State.IN_PLAY)

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
