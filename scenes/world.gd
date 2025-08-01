extends Node2D

func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
