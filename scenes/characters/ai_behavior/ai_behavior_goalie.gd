class_name AIBehaviorGoalie
extends AIBehavior

const PROXIMITY_CONCERN := 10.0

func perform_ai_movement() -> void:
	var total_steering_force := get_goalie_steering_force()
	
	
	
	total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = total_steering_force * player.movement_speed

func performa_ai_decisions() -> void:
	pass

func get_goalie_steering_force() -> Vector2:
	var top_goal := player.own_goal.get_goal_point(1)
	var bottom_goal := player.own_goal.get_goal_point(3)
	var center := player.spawn_position
	var target_y := clampf(ball.position.y, top_goal.y, bottom_goal.y)
	var destination := Vector2(center.x,target_y)
	var direction := player.global_position.direction_to(destination)
	var distance_to_destination := player.global_position.distance_to(destination)
	var weight := clampf(distance_to_destination / PROXIMITY_CONCERN, 0, 1)
	
	return weight * direction
