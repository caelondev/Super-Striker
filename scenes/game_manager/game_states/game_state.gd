class_name GameState
extends Node

signal state_tranaition_requested(new_statw: GameManager.State, data: GameStateData)

var manager : GameManager = null
var state_data : GameStateData = null

func setup(c_manager: GameManager, data: GameStateData) -> void:
	manager = c_manager
	state_data = data

func transition_state(new_state: GameManager.State, data: GameStateData = GameStateData.new()) -> void:
	state_tranaition_requested.emit(new_state, data)

func show_mobile_ui() -> bool:
	return false
