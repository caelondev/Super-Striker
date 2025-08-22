class_name BallStateShot      
extends BallState      
	  
const BALL_SPRITE_SCALE := 0.8
const SHOT_DURATION := 1000
const SHOT_HEIGHT := 5

var time_start_shooting := Time.get_ticks_msec()

func _enter_tree():
	handle_animation()
	ball_sprite.scale.y = BALL_SPRITE_SCALE      
	ball.height = SHOT_HEIGHT

func _physics_process(delta):
	if Time.get_ticks_msec() - time_start_shooting > SHOT_DURATION:
		transition_state(Ball.State.FREEFORM)
	else:
		move_and_bounce(delta)

func can_summon_shot_particle() -> bool:
	return true

func _exit_tree():
	ball_sprite.scale.y = 1
