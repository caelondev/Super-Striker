class_name MainMenu
extends Control

const MENU_TEXTURE := [
	[preload("res://assets/art/ui/mainmenu/1-player.png"), preload("res://assets/art/ui/mainmenu/1-player-selected.png")],
	[preload("res://assets/art/ui/mainmenu/2-players.png"), preload("res://assets/art/ui/mainmenu/2-players-selected.png")]
]

@onready var selectable_menu_nodes : Array[TextureRect] = [%SingleplayerTexture, %TwoPlayerTexture]
@onready var selection_icon : TextureRect = %SelectionIcon
@onready var start_icon : TextureRect = %Start

var current_selected_index := 0
var animation_ended := false

func _ready() -> void:
	for i in range(selectable_menu_nodes.size()):
		selectable_menu_nodes[i].gui_input.connect(on_menu_input.bind(i))
	start_icon.gui_input.connect(func(e) -> void:
		if e.is_pressed():
			submit_selection()
	)
	refresh_ui()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		submit_selection()

func refresh_ui() -> void:
	for i in range(selectable_menu_nodes.size()):
		if current_selected_index == i:
			selectable_menu_nodes[i].texture = MENU_TEXTURE[i][1]
			selection_icon.position.y = selectable_menu_nodes[i].position.y
		else:
			selectable_menu_nodes[i].texture = MENU_TEXTURE[i][0]

func change_selected_index() -> void:
	if not animation_ended:
		return
	current_selected_index += 1
	if current_selected_index > selectable_menu_nodes.size() - 1:
		current_selected_index = 0
	AudioManager.play(AudioManager.Audio.UI_NAV)
	refresh_ui()

func on_menu_input(event: InputEvent, index: int) -> void:
	if event.is_pressed():
		change_selected_index()

func submit_selection() -> void:
	if not animation_ended:
		return
	
	var country_default := DataLoader.get_countries()[1]
	AudioManager.play(AudioManager.Audio.UI_SELECT)
	var player_two := "" if current_selected_index == 0 else country_default
	GameManager.player_setup = ["FRANCE", player_two]

func animation_complete() -> void:
	refresh_ui()
	animation_ended = true
