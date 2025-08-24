class_name GameStateGameOver
extends GameState

func _enter_tree() -> void:
	GameManager.time_left = GameManager.DURATION_GAME_SEC
	var country_winner := manager.get_winner_country()
	GameEvents.game_over.emit(country_winner)
