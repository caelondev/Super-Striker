extends Node2D

@onready var mobile_ui = %MobileUI

func _ready():
	mobile_ui.show()

func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
