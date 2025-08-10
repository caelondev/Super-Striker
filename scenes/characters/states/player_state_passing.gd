class_name PlayerStatePassing
extends PlayerState

func _enter_tree():
	animation_player.play("Kick")
	player.velocity = Vector2.ZERO

func animation_complete() -> void:
	var closest_teammate = find_team_closest()
	print(closest_teammate)
	transition_state(Player.State.MOVING)
	
func find_team_closest() -> Player:
	var players_in_view := teammate_detection_area.get_overlapping_bodies()
	var team_in_view := players_in_view.filter(
		func(p: Player): return p != player
	)
	if team_in_view.is_empty():
		return null
	team_in_view.sort_custom(
		func(p1: Player, p2: Player): return p1.position.distance_squared_to(player.position) < p2.position.distance_squared_to(player.position) 
	)
	if team_in_view.size() > 0:
		return team_in_view[0]
	return null
