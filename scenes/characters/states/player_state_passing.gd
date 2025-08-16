class_name PlayerStatePassing  
extends PlayerState  
  
func _enter_tree():  
	animation_player.play("Kick")  
	player.velocity = Vector2.ZERO  
  
func animation_complete() -> void:  
	var colliding_player = check_colliding_player()  
	if colliding_player != null:
		ball.pass_to(colliding_player.position + colliding_player.velocity)
	else:
		colliding_player = check_nearest_player()
		if colliding_player != null:
			ball.pass_to(colliding_player.position + colliding_player.velocity)  
		else:
			var raycast_direction = teammate_detection_ray.global_transform.x
			ball.pass_to(ball.position + raycast_direction * player.movement_speed)
	transition_state(Player.State.MOVING)  

func check_nearest_player() -> Player:
	var players = teammate_detection_area.get_overlapping_bodies()
	var valid_players = []
	
	for p in players:
		if p is Player and p != player and p.role != Player.Role.GOALIE:
			valid_players.append(p)
	
	if valid_players.is_empty():
		return null
		
	valid_players.sort_custom(func(p1: Player, p2: Player) -> bool: 
		return p1.global_position.distance_squared_to(player.global_position) < p2.global_position.distance_squared_to(player.global_position))
	
	return valid_players[0]

func check_colliding_player() -> Player:  
	if teammate_detection_ray.is_colliding():  
		var player_in_view = teammate_detection_ray.get_collider()  
		if player_in_view is Player and player_in_view.role != Player.Role.GOALIE:  
			return player_in_view  
	return null
