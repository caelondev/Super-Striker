class_name Camera
extends Camera2D

const DISTANCE_TARGET := 100
const SMOOTHING_BALL_CARRIED = 1.5
const SMOOTHING_BALL_DEFAULT = 3

@export var ball : Ball

func _physics_process(_delta):
	if ball.carrier != null:
		position_smoothing_speed = SMOOTHING_BALL_CARRIED
		global_position = ball.carrier.global_position + ball.carrier.heading * DISTANCE_TARGET
	else:
		position_smoothing_speed = SMOOTHING_BALL_DEFAULT
		global_position = ball.global_position
