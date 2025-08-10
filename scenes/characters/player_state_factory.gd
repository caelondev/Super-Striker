class_name PlayerStateFactory

var states : Dictionary

func _init():
	states = {
		Player.State.MOVING: PlayerStateMoving,
		Player.State.PASSING: PlayerStatePassing,
		Player.State.PREP_SHOT: PlayerStatePreppingShot,
		Player.State.SHOOTING: PlayerStateShooting,
		Player.State.TACKLING: PlayerStateTackling,
		Player.State.RECOVERING: PlayerStateRecovering,
	}

func get_fresh_tates(state: Player.State) -> PlayerState:
	assert(states.has(state), "State: " + str(state) + " not found")
	return states.get(state).new()
