class_name GameStateKickoff
extends GameState

const DURATION_WAIT := 500

var time_enter := Time.get_ticks_msec()

func _enter_tree() -> void:
	manager.ready_players = 0

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - time_enter < DURATION_WAIT:
		return
	if Input.is_action_just_pressed("continue") or KeyUtils.get_screen_pressed():
		GameEvents.start_kickoff.emit()
		AudioManager.play(AudioManager.Audio.WHISTLE)
		transition_state(GameManager.State.IN_PLAY)
