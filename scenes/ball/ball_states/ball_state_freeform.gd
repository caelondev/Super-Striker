class_name BallStateFreeform
extends BallState

const MAX_CAPTURE_HEIGHT := 25
var time_since_freeform := Time.get_ticks_msec()

func _enter_tree():
	player_detection_area.body_entered.connect(on_player_pickup.bind())

func _physics_process(delta: float) -> void:
	player_detection_area.monitoring = (Time.get_ticks_msec() - time_since_freeform > state_data.lock_duration)
	handle_animation()
	process_gravity(delta, ball.BOUNCINESS)
	var friction = ball.FRICTION_AIR if ball.height > 0 else ball.FRICTION_GROUND
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_bounce(delta)

func on_player_pickup(body: Player) -> void:
	if body.can_carry_ball() and ball.height < MAX_CAPTURE_HEIGHT:
		ball.carrier = body
		body.control_ball()
		transition_state(Ball.State.CARRIED)

func can_air_interact() -> bool:
	return true
