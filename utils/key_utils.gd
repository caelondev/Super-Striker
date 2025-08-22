extends Node

enum Action {LEFT, RIGHT, UP, DOWN, SHOOT, PASS, SWAP}

const ACTIONS_MAP : Dictionary = {
	Player.ControlScheme.P1: {
		Action.LEFT: "p1_walk_left",
		Action.RIGHT: "p1_walk_right",
		Action.UP: "p1_walk_up",
		Action.DOWN: "p1_walk_down",
		Action.SHOOT: "p1_shoot",
		Action.PASS: "p1_pass",
		Action.SWAP: "p1_swap",
	},
	Player.ControlScheme.P2: {
		Action.LEFT: "p2_walk_left",
		Action.RIGHT: "p2_walk_right",
		Action.UP: "p2_walk_up",
		Action.DOWN: "p2_walk_down",
		Action.SHOOT: "p2_shoot",
		Action.PASS: "p2_pass",
		Action.SWAP: "p2_swap",
	},	
}

var _is_screen_pressed := false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		_is_screen_pressed = true
	else:
		_is_screen_pressed = false

func get_input_vector(scheme: Player.ControlScheme) -> Vector2:
	var map : Dictionary = ACTIONS_MAP[scheme]
	return Input.get_vector(map[Action.LEFT], map[Action.RIGHT], map[Action.UP], map[Action.DOWN])

func get_actions_pressed(scheme: Player.ControlScheme, action: Action) -> bool:
		return Input.is_action_pressed(ACTIONS_MAP[scheme][action])
	
func get_actions_just_pressed(scheme: Player.ControlScheme, action: Action) -> bool:
	return Input.is_action_just_pressed(ACTIONS_MAP[scheme][action])

func get_actions_just_released(scheme: Player.ControlScheme, action: Action) -> bool:
	return Input.is_action_just_released(ACTIONS_MAP[scheme][action])

func get_screen_pressed() -> bool:
	return _is_screen_pressed
