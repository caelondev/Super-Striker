class_name Screen
extends Node

signal screen_transition_requested(new_screen: SuperStriker.ScreenType, data: ScreenData)

var game : SuperStriker = null
var screen_data : ScreenData = null

func setup(c_game: SuperStriker, c_screen_data: ScreenData) -> void:
	game = c_game
	screen_data = c_screen_data

func transition_screen(new_screen: SuperStriker.ScreenType, data: ScreenData = ScreenData.build()):
	screen_transition_requested.emit(new_screen, data)
