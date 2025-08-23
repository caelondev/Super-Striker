class_name WorldScreen
extends Screen

@onready var mobile_ui := %MobileUI
@onready var game_ui := %UI
@onready var actors_container := %ActorsContainer

var players : Array[Player] = []

func _enter_tree() -> void:
	GameManager.start_game()

func _ready() -> void:
	game_ui.show()
	if not GameManager.player_setup[0].is_empty():
		players.append(actors_container.player_1)
	if not GameManager.player_setup[1].is_empty():
		mobile_ui.has_two_players = true
		players.append(actors_container.player_2)

func _physics_process(delta):
	var hide_ui := false
	for player: Player in players:
		hide_ui = not player.current_state.is_mobile_ui_shown()

	if hide_ui:
		mobile_ui.disable_joysticks()
		mobile_ui.hide()
	else:
		mobile_ui.enable_joysticks()
		mobile_ui.show()
