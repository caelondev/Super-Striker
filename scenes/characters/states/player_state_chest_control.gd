class_name PlayerStateChestControl
extends PlayerState

const DURATION := 250

var time_since_start := Time.get_ticks_msec()

func _enter_tree():
	animation_player.play("ChestControl")
	player.height = 0
	player.velocity = Vector2.ZERO

func _process(delta):
	if Time.get_ticks_msec() - time_since_start > DURATION:
		transition_state(Player.State.MOVING)
