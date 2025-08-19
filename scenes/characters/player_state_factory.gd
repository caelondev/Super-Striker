class_name PlayerStateFactory

var states : Dictionary

func _init():
	states = {
		Player.State.BICYCLE_KICK: PlayerStateBicycleKick,
		Player.State.CELEBRATING: PlayerStateCelebrating,
		Player.State.CHEST_CONTROL: PlayerStateChestControl,
		Player.State.DIVING: PlayerStateDiving,
		Player.State.HEADER: PlayerStateHeader,
		Player.State.HURT: PlayerStateHurt,
		Player.State.MOVING: PlayerStateMoving,
		Player.State.MOURNING: PlayerStateMourning,
		Player.State.PASSING: PlayerStatePassing,
		Player.State.PREP_SHOT: PlayerStatePreppingShot,
		Player.State.RECOVERING: PlayerStateRecovering,
		Player.State.RESETTING: PlayerStateResetting,
		Player.State.SHOOTING: PlayerStateShooting,
		Player.State.TACKLING: PlayerStateTackling,
		Player.State.VOLLEY_KICK: PlayerStateVolleyKick,
	}

func get_fresh_tates(state: Player.State) -> PlayerState:
	assert(states.has(state), "State: " + str(state) + " not found")
	return states.get(state).new()
