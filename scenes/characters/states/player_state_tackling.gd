class_name PlayerStateTackling
extends PlayerState

const TACKLE_DURATION := 200

var time_start_tackle := Time.get_ticks_msec()

func _enter_tree() -> void:
	animation_player.play("Tackle")
	time_start_tackle = Time.get_ticks_msec()

func _process(_delta) -> void:
	if Time.get_ticks_msec() - time_start_tackle > TACKLE_DURATION:
		state_transition_requested.emit(Player.State.MOVING)
