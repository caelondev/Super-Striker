class_name PlayerStateCelebrating
extends PlayerState

const AIR_FRICTION := 60
const CELEBRATING_HEIGHT := 2.0

var initial_delay := randf_range(0, 800)
var time_since_delay := Time.get_ticks_msec()

func _enter_tree() -> void:
	GameEvents.team_reset.connect(on_team_reset.bind())
	celebrate()

func _physics_process(delta: float) -> void:
	if player.height <= 0 and Time.get_ticks_msec() - time_since_delay > initial_delay:
		celebrate()
	player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * AIR_FRICTION)

func on_team_reset() -> void:
	var data := PlayerStateData.build().set_reset_position(player.spawn_position)
	transition_state(Player.State.RESETTING, data)

func celebrate() -> void:
	animation_player.play("Celebrate")
	player.height = 0.1
	player.height_velocity = CELEBRATING_HEIGHT

func is_mobile_ui_shown() -> bool:
	return false
