extends Control

signal disable_button(button : String, control_scheme: Player.ControlScheme)
signal enable_button(button : String, control_scheme: Player.ControlScheme)

@onready var player_one_control_buttons := %Player_1
@onready var player_two_control_buttons := %Player_2
@onready var player_one_joystick := %TouchScreenJoystick
@onready var player_two_joystick := %TouchScreenJoystick2

var has_two_players = false

func _ready() -> void:
	disable_button.connect(cooldown_button.bind())
	enable_button.connect(ready_button.bind())

func ready_button(button : String, control_scheme: Player.ControlScheme) -> void:
	var buttons = get_player_control(control_scheme)
	for b in buttons:
		if b.name == button:
			b.is_on_cooldown = false
			# Hide cooldown label when ready
			if b.has_node("CooldownLabel"):
				b.get_node("CooldownLabel").visible = false

func cooldown_button(button : String, control_scheme: Player.ControlScheme) -> void:
	var buttons = get_player_control(control_scheme)
	for b in buttons:
		if b.name == button:
			b.is_on_cooldown = true
			if b.has_node("CooldownLabel"):
				b.get_node("CooldownLabel").visible = true

func update_cooldown_display(button_name: String, control_scheme: Player.ControlScheme, time_left_ms: int) -> void:
	var buttons = get_player_control(control_scheme)
	for b in buttons:
		if b.name == button_name and b.has_node("CooldownLabel"):
			var cooldown_label = b.get_node("CooldownLabel")
			if time_left_ms > 0:
				var seconds_left = ceil(float(time_left_ms) / 1000.0)
				cooldown_label.text = str(int(seconds_left))
				cooldown_label.visible = true
			else:
				cooldown_label.visible = false

func _process(delta: float) -> void:
	if has_two_players:
		player_two_control_buttons.show()
		player_two_joystick.use_input_actions = true
	else:
		player_two_control_buttons.hide()
		player_two_joystick.use_input_actions = false

func get_player_control(player_control_scheme: Player.ControlScheme) -> Array[Node]:
	if player_control_scheme == Player.ControlScheme.P1:
		return player_one_control_buttons.get_children()
	elif player_control_scheme == Player.ControlScheme.P2:
		return player_two_control_buttons.get_children()
	return []

func disable_joysticks() -> void:
	player_one_joystick.use_input_actions = false
	player_two_joystick.use_input_actions = false
