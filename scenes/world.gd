extends Node2D

@onready var mobile_ui := %MobileUI
@onready var actors_container := %ActorsContainer

func _ready():
	mobile_ui.show()

func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

	# collect active players
	var players := []
	if actors_container.player_1 != null:
		players.append(actors_container.player_1)
	if actors_container.two_player and actors_container.player_2 != null:
		players.append(actors_container.player_2)

	# check if any player's state blocks the UI
	var hide_ui := players.any(func(p): return not p.current_state.is_mobile_ui_shown())

	# apply result
	if hide_ui:
		mobile_ui.disable_joysticks()
		mobile_ui.hide()
	else:
		mobile_ui.enable_joysticks()
		mobile_ui.show()
