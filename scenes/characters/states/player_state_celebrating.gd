class_name PlayerStateCelebrating
extends PlayerState

const AIR_FRICTION := 35
const CELEBRATING_HEIGHT := 2.0

func _enter_tree() -> void:
	GameEvents.team_reset.connect(on_team_reset.bind())
	celebrate()

func _physics_process(delta: float) -> void:
	if player.height <= 0:
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
