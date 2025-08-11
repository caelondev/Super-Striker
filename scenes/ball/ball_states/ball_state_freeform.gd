class_name BallStateFreeform
extends BallState

func _enter_tree():
	player_detection_area.body_entered.connect(on_player_pickup.bind())

func _process(delta):
	handle_animation()
	process_gravity(delta, ball.BOUNCINESS)
	var friction = ball.FRICTION_AIR if ball.height > 0 else ball.FRICTION_GROUND
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_bounce(delta)

func on_player_pickup(body: Player) -> void:
	ball.carrier = body
	ball.switch_state(Ball.State.CARRIED)

func can_air_interact() -> bool:
	return true
