class_name AIBehaviorField
extends AIBehavior

const PASS_PROBABILITY := 0.2
const SHOT_DISTANCE := 150
const SHOT_PROBABILITY := 0.15
const SPREAD_ASSIST_FACTOR := 0.8
const TACKLE_DISTANCE := 15
const TACKLE_PROBABILITY := 0.15

func perform_ai_movement() -> void:
	var total_steering_force := Vector2.ZERO
	if player.is_carrying_ball():
		total_steering_force += get_carrier_steering_force()
	elif is_ball_carried_by_teammate():
		total_steering_force += get_assist_formation_steering_force()
	else:
		total_steering_force += get_onduty_steering_force()
		if total_steering_force.length_squared() < 1:
			if is_ball_possessed_by_opponent():
				total_steering_force += get_spawn_steering_force()
			elif ball.carrier == null:
				total_steering_force += get_ball_proximity_steering_force()
	
	total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = total_steering_force * player.movement_speed

func perform_ai_decisions() -> void:
	if player.role != Player.Role.GOALIE:
		if is_ball_possessed_by_opponent() and player.position.distance_to(ball.position) < TACKLE_DISTANCE and randf() < TACKLE_PROBABILITY:
			player.switch_state(Player.State.TACKLING)
		if ball.carrier == player:
			var target := player.target_goal.get_goal_point(2)
			if player.position.distance_to(target) < SHOT_DISTANCE and randf() < SHOT_PROBABILITY:
				face_towards_target_goal()
				var shot_direction := player.position.direction_to(player.target_goal.get_random_target_position())
				var data := PlayerStateData.build().set_shot_power(player.power).set_shot_direction(shot_direction)
				player.switch_state(Player.State.SHOOTING, data)
			elif has_opponents_nearby() and randf() < PASS_PROBABILITY:
				if has_opponents_nearby():
					player.switch_state(Player.State.PASSING)

func get_onduty_steering_force() -> Vector2:
	if ball.carrier != null:
		return player.weight_on_duty_stearing * player.global_position.direction_to(ball.carrier.global_position)
	return player.weight_on_duty_stearing * player.position.direction_to(ball.position)

func get_carrier_steering_force() -> Vector2:
	var target := player.target_goal.get_goal_point(2)
	var direction := player.position.direction_to(target)
	var weight := get_bicircular_weight(player.position, target, 100, 0, 150, 1)
	return weight * direction

func get_assist_formation_steering_force() -> Vector2:
	var spawn_difference := ball.carrier.spawn_position - player.spawn_position
	var assist_destination := ball.carrier.position - spawn_difference * SPREAD_ASSIST_FACTOR
	var direction := player.position.direction_to(assist_destination)
	var weight := get_bicircular_weight(player.position, assist_destination, 30, 0.2, 60, 1)
	return weight * direction

func get_ball_proximity_steering_force() -> Vector2:
	var weight := get_bicircular_weight(player.global_position, ball.global_position, 50, 1, 120, 0)
	var direction := player.global_position.direction_to(ball.global_position)
	return weight * direction
	
func get_spawn_steering_force() -> Vector2: 
	var weight := get_bicircular_weight(player.global_position, player.spawn_position, 30, 0, 100, 1)
	var direction := player.global_position.direction_to(player.spawn_position)
	return weight * direction

func has_teammate_in_range() -> bool:
	if teammate_detection_ray.is_colliding():
		var collider : Player = teammate_detection_ray.get_collider()
		return collider != player and collider.country == player.country and collider.role != Player.Role.GOALIE
	else:
		var players := teammate_detection_area.get_overlapping_bodies()
		return players.find_custom(func(p: Player): return p != player and p.country == player.country and p.role != Player.Role.GOALIE) > -1
