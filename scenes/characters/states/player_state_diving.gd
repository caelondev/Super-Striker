class_name PlayerStateDiving
extends PlayerState

const DIVE_DURATION := 500

var time_since_dive := Time.get_ticks_msec()

func _enter_tree() -> void:
	var target_dive := Vector2.ZERO
	if ball.carrier != null:
		target_dive = Vector2(player.spawn_position.x, ball.carrier.global_position.y)
	else:
		target_dive = Vector2(player.spawn_position.x, ball.global_position.y)
		
	var direction = player.global_position.direction_to(target_dive)
	player.velocity = direction * player.movement_speed
	if direction.y > 0:
		animation_player.play("DiveDown")
	else:
		animation_player.play("DiveUp")

func _physics_process(delta: float) -> void:
	if Time.get_ticks_msec() - time_since_dive > DIVE_DURATION:
		transition_state(Player.State.RECOVERING)
		time_since_dive = Time.get_ticks_msec()
