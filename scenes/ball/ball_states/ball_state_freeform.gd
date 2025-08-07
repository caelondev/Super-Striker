class_name BallStateFreeform
extends BallState

func _enter_tree():
	player_detection_area.body_entered.connect(on_player_pickup.bind())

func on_player_pickup(body: Player) -> void:
	ball.carrier = body
	state_transition_requested.emit(Ball.State.CARRIED)
