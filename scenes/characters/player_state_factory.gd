class_name PlayerStateFactory

var states : Dictionary

func _init():
	states = {
		Player.State.MOVING: PlayerStateMoving,
		Player.State.TACKLE: PlayerStateTackling,
	}

func get_fresh_tates(state: Player.State) -> PlayerState:
	assert(states.has(state), "State: " + str(state) + " not found")
	return states.get(state).new()
