class_name BallStateCarried
extends BallState

const BALL_TO_PLAYER_OFFSET := Vector2(10, 4)
const DRIBBLE_FREQUENCY := 10.0
const DRIBBLE_INTENSITY := 4.0

var dribble_time := 0.0

func _enter_tree():
	assert(carrier != null)

func _physics_process(delta):
	process_gravity(delta)
	var vx := 0.0
	dribble_time += delta
	if carrier.velocity != Vector2.ZERO:
		if abs(carrier.velocity.x) > 7:
			vx += cos(dribble_time * DRIBBLE_FREQUENCY) * DRIBBLE_INTENSITY
		if carrier.velocity.x > 0:
			animation_player.play("Roll")
			animation_player.advance(0)
		elif carrier.velocity.x < 0:
			animation_player.play_backwards("Roll")
			animation_player.advance(0)
	else:
		animation_player.play("Idle")
	
	ball.global_position = carrier.global_position + Vector2(vx + carrier.heading.x * BALL_TO_PLAYER_OFFSET.x, BALL_TO_PLAYER_OFFSET.y)
