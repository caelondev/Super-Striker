class_name WorldScreen
extends Screen

@onready var mobile_ui := %MobileUI
@onready var game_ui := %UI
@onready var gameover_timer := %GameOverTimer
@onready var actors_container := %ActorsContainer

var players : Array[Player] = []

func _enter_tree() -> void:
	GameEvents.game_over.connect(on_gameover.bind())

func _ready() -> void:
	game_ui.show()
	GameManager.start_game()
	if not GameManager.player_setup[0].is_empty():
		players.append(actors_container.player_1)
	if not GameManager.player_setup[1].is_empty():
		mobile_ui.has_two_players = true
		players.append(actors_container.player_2)
	gameover_timer.timeout.connect(on_gameover_timeout.bind())

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

func on_gameover_timeout() -> void:
	if screen_data.tournament != null and GameManager.current_match.winner == GameManager.player_setup[0]:
		screen_data.tournament.advance()
		transition_screen(SuperStriker.ScreenType.TOURNAMENT, screen_data)
	else:
		transition_screen(SuperStriker.ScreenType.MAIN_MENU)
	AudioManager.play(AudioManager.Audio.UI_SELECT)

func on_gameover(_c: String) -> void:
	gameover_timer.start()
