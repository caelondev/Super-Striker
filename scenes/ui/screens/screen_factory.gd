class_name ScreenFactory
extends Node

var screens : Dictionary

func _init() -> void:
	screens = {
		SuperStriker.ScreenType.MAIN_MENU: preload("res://scenes/ui/screens/main_menu/main_menu_ui.tscn"),
		SuperStriker.ScreenType.TEAM_SELECTION: preload("res://scenes/ui/screens/team_selection/team_selection_menu.tscn"),
		SuperStriker.ScreenType.IN_GAME: preload("res://scenes/ui/screens/world/world.tscn"),
	}

func get_fresh_screen(new_screen: SuperStriker.ScreenType) -> Screen:
	assert(screens.has(new_screen))
	return screens.get(new_screen).instantiate()
