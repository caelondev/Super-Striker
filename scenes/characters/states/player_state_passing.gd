class_name PlayerStatePassing
extends PlayerState

func _enter_tree():
	animation_player.play("Kick")
	player.velocity = Vector2.ZERO

func animation_complete() -> void:
	var colliding_player = check_colliding_team()
	if colliding_player == null:
		ball.pass_to(ball.position + player.heading * player.movement_speed)
	else:
		ball.pass_to(colliding_player.position + colliding_player.velocity)
	transition_state(Player.State.MOVING)

func check_colliding_team() -> Player:
	var player_in_view : Player = null
	if teammate_detection_ray.is_colliding():
		player_in_view = teammate_detection_ray.get_collider()
		if player_in_view.country == player.country and player_in_view.role != Player.Role.GOALIE:
			return player_in_view
	return null
	
