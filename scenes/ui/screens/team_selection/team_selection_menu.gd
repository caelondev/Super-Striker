class_name TeamSelectionMenu
extends Screen

const FLAG_ANCHOR_POINT := Vector2(70, 50)
const FLAG_TEMPLATE_SCENE := preload("res://scenes/ui/flag_template.tscn")
const FLAG_SELECTOR_SCENE := preload("res://scenes/ui/screens/team_selection/flag_selector.tscn")
const NB_COLS := 4
const NB_ROWS := 2

@onready var enter_button := %Enter
@onready var flags_container := %FlagsContainer
@onready var player_two_menu := [%Select2, $TeamSelectionButtons2]

var move_dirs : Dictionary[KeyUtils.Action, Vector2i] = {
	KeyUtils.Action.UP: Vector2i.UP,
	KeyUtils.Action.DOWN: Vector2i.DOWN,
	KeyUtils.Action.LEFT: Vector2i.LEFT,
	KeyUtils.Action.RIGHT: Vector2i.RIGHT,
}
var selection : Array[Vector2i] = [Vector2i.ZERO, Vector2i.ZERO]
var selectors : Array[FlagSelector] = []
var all_selected := false

func _ready() -> void:
	call_deferred("place_flags")
	call_deferred("place_selectors")
	for button in player_two_menu:
		button.visible = GameManager.player_setup[1] != ""

func _process(delta: float) -> void:
	for i in range(selectors.size()):
		var selector : FlagSelector = selectors[i]
		if not selector.is_selected:
			for action: KeyUtils.Action in move_dirs.keys():
				if KeyUtils.get_actions_just_pressed(selector.control_scheme, action):
					try_navigate(i, move_dirs[action])
		if Input.is_action_just_pressed("ui_accept"):
			AudioManager.play(AudioManager.Audio.UI_NAV)
			transition_screen(SuperStriker.ScreenType.IN_GAME)
		if Input.is_action_just_pressed("ui_cancel"):
			AudioManager.play(AudioManager.Audio.UI_NAV)
			transition_screen(SuperStriker.ScreenType.MAIN_MENU)
	update_enter()

func update_enter() -> void:
	for selector in selectors:
		if selector.is_selected:
			all_selected = true
		else:
			all_selected = false
			break
	
	if all_selected:
		enter_button.show()
	else:
		enter_button.hide()

func try_navigate(selection_index: int, direction: Vector2i) -> void:
	var rect : Rect2i = Rect2(0, 0, NB_COLS, NB_ROWS)
	if rect.has_point(selection[selection_index] + direction):
		selection[selection_index] += direction
		var flag_index := selection[selection_index].x + selection[selection_index].y * NB_COLS
		GameManager.player_setup[selection_index] = DataLoader.get_countries()[1 + flag_index]
		selectors[selection_index].global_position = flags_container.get_child(flag_index).global_position
		AudioManager.play(AudioManager.Audio.UI_NAV)

func place_flags() -> void:
	for j in range(NB_ROWS):
		for i in range(NB_COLS):
			var flag_texture := FLAG_TEMPLATE_SCENE.instantiate()
			var country_index := 1 + i + NB_COLS * j
			var country := DataLoader.get_countries()[country_index]
			flag_texture.texture = FlagHelper.get_texture(country)
			flag_texture.name = country.to_upper()
			flags_container.add_child(flag_texture)
			flag_texture.position = FLAG_ANCHOR_POINT + Vector2(55 * i, 50 * j) + Vector2.ONE

func place_selectors() -> void:
	add_selector(Player.ControlScheme.P1)
	if not GameManager.player_setup[1].is_empty():
		add_selector(Player.ControlScheme.P2)

func add_selector(control_scheme: Player.ControlScheme) -> void:
	var selector := FLAG_SELECTOR_SCENE.instantiate()
	selector.selected.connect(on_selector_selected.bind())
	selector.global_position = flags_container.get_child(0).global_position
	selector.control_scheme = control_scheme
	selectors.append(selector)
	flags_container.add_child(selector)

func on_selector_selected() -> void:
	for selector in selectors:
		if not selector.is_selected:
			return
		var country_p1 := GameManager.player_setup[0]
		var country_p2 := GameManager.player_setup[1]
		if not country_p2.is_empty():
			if country_p1 != country_p2:
				GameManager.countries = [country_p1, country_p2]
				transition_screen(SuperStriker.ScreenType.IN_GAME)
	
