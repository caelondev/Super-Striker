class_name BallStateFreeform
extends BallState

const BOUNCINESS := 0.8
const FRICTION_AIR := 35.0
const FRICTION_GROUND := 250.0

func _enter_tree():
	player_detection_area.body_entered.connect(on_player_pickup.bind())

func _process(delta):
	handle_animation()
	process_gravity(delta, BOUNCINESS)
	var friction = FRICTION_AIR if ball.height > 0 else FRICTION_GROUND
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, friction * delta)
	ball.move_and_collide(ball.velocity * delta)

func on_player_pickup(body: Player) -> void:
	ball.carrier = body
	state_transition_requested.emit(Ball.State.CARRIED)
