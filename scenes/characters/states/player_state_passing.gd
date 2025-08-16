class_name PlayerStatePassing  
extends PlayerState  
  
func _enter_tree():  
	animation_player.play("Kick")  
	player.velocity = Vector2.ZERO  
  
func animation_complete() -> void:  
	var colliding_player = check_nearest_player()
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
	if teammate_detection_ray.is_colliding():
		var collider = teammate_detection_ray.get_collider()
		if collider is Player and collider != player and collider.role != Player.Role.GOALIE:
			return collider
	
	var players := teammate_detection_area.get_overlapping_bodies()
	for p in players:
		if p is Player and p != player and p.country == player.country and p.role != Player.Role.GOALIE:
			return p
	
	return null
