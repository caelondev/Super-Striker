class_name PlayerStateHeader
extends PlayerState

const BALL_HEIGHT_MIN := 5
const BALL_HEIGHT_MAX := 70
const BONUS_POWER := 1.3
const HEIGHT_INIT := 6
const HEIGHT_VELOCITY := 1.5

func _enter_tree():
	animation_player.play("Header")
	player.height = HEIGHT_INIT
	player.height_velocity = HEIGHT_VELOCITY
	ball_detection_area.body_entered.connect(on_ball_enter.bind())

func on_ball_enter(contact_ball: Ball) -> void:
	if contact_ball.can_air_connect(BALL_HEIGHT_MIN, BALL_HEIGHT_MAX):
		contact_ball.shoot(player.velocity.normalized() * player.power * BONUS_POWER)

func _process(_delta) -> void:
	if player.height <= 0:
		transition_state(Player.State.RECOVERING)
