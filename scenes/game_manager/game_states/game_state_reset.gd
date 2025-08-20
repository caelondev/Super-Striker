class_name GameStateReset
extends GameState

func _enter_tree() -> void:
	GameEvents.team_reset.emit()
