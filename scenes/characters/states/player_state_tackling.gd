class_name PlayerStateTackling
extends PlayerState

const DURATION_PRIOR_RECOVERY := 200
const GROUND_FRICTION := 250.0

var is_tackle_complete := false
var time_finish_tackle := Time.get_ticks_msec()

func _enter_tree() -> void:
	tackle_damage_emitter.monitoring = true
	animation_player.play("Tackle")
	time_finish_tackle = Time.get_ticks_msec()

func _exit_tree() -> void:
	tackle_damage_emitter.monitoring = false

func _process(delta) -> void:
	if not is_tackle_complete:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * GROUND_FRICTION)
		if player.velocity == Vector2.ZERO:
			is_tackle_complete = true
	elif Time.get_ticks_msec() - time_finish_tackle > DURATION_PRIOR_RECOVERY:
		transition_state(Player.State.RECOVERING)
