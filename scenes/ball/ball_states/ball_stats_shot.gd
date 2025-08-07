class_name BallStateShot
extends BallState

const BALL_SPRITE_SCALE = 0.8

func _enter_tree():
	if ball.velocity.x >= 0:
		animation_player.play("Roll")
		animation_player.advance(0)
	else:
		animation_player.play_backwards("Roll")
		animation_player.advance(0)
	ball_sprite.scale.y = BALL_SPRITE_SCALE

func _physics_process(delta):
	ball.move_and_collide(ball.velocity * delta)

func _exit_tree():
	ball_sprite.scale.y = 1
