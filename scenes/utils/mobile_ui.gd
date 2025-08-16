extends Control

@onready var player_two_control_buttons := %Player_2
@onready var player_two_joystick := %TouchScreenJoystick2

var has_two_players = false

func _process(delta: float) -> void:
	if has_two_players:
		player_two_control_buttons.show()
		player_two_joystick.use_input_actions = true
	else:
		player_two_control_buttons.hide()
		player_two_joystick.use_input_actions = false
