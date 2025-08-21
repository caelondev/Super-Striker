class_name PlayerStateResetting
extends PlayerState

var has_arrived := false

func _physics_process(delta: float) -> void:
	if not has_arrived:
		var direction := player.global_position.direction_to(player_state_data.reset_position)
		if player.global_position.distance_squared_to(player_state_data.reset_position) < 2:
			has_arrived = true
			player.velocity = Vector2.ZERO
			GameEvents.player_ready.emit()
			player.face_towards_target_goal()
		else:
			player.velocity = direction * player.movement_speed
		player.handle_animations()
		player.set_heading()

func is_mobile_ui_shown() -> bool:
	return false
