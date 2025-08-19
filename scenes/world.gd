extends Node2D

@onready var mobile_ui = %MobileUI

func _ready():
	GameEvents.team_scored.connect(on_team_scored.bind())
	mobile_ui.show()

func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

func on_team_scored(_team: String) -> void:
	mobile_ui.disable_joysticks()
	mobile_ui.hide()
