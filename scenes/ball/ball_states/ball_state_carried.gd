class_name BallStateCarried
extends BallState

func _enter_tree():
	assert(carrier != null)

func _physics_process(delta):
	ball.global_position = carrier.global_position
