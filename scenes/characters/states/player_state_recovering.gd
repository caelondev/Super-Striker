class_name PlayerStateRecovering
extends PlayerState

const DURATION_RECOVERY := 500

var time_start_recovery : float

func _enter_tree() -> void:
	time_start_recovery = Time.get_ticks_msec()
	player.velocity = Vector2.ZERO
	animation_player.play("Recover")

func _process(delta) -> void:
	if Time.get_ticks_msec() - time_start_recovery > DURATION_RECOVERY:
		transition_state(Player.State.MOVING)
