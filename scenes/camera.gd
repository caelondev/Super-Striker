class_name Camera
extends Camera2D

const DISTANCE_TARGET := 100
const DURATION_SHAKE := 100
const SHAKE_INTENSITY := 5
const SMOOTHING_BALL_CARRIED = 1.5
const SMOOTHING_BALL_DEFAULT = 3
const ZOOM_DISTANCE := Vector2(1.0, 1.0) * 1.5
const FREECAM_BUFFER := Vector2.DOWN * 15

@export var ball : Ball

var is_screen_shaking := false
var time_since_last_shake := Time.get_ticks_msec()
var is_on_freecam := false
var target_zoom := Vector2.ONE

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func _ready() -> void:
	GameEvents.impact_received.connect(on_impact_received.bind())
	GameEvents.team_scored.connect(on_team_scored.bind())
	GameEvents.game_over.connect(on_game_over.bind())
	GameEvents.team_reset.connect(on_team_reset.bind())

func _physics_process(delta):
	if not is_on_freecam:
		target_zoom = Vector2.ONE
		if ball.carrier != null:
			position_smoothing_speed = SMOOTHING_BALL_CARRIED
			global_position = ball.carrier.global_position + ball.carrier.heading * DISTANCE_TARGET
		else:
			position_smoothing_speed = SMOOTHING_BALL_DEFAULT
			global_position = ball.global_position
	else:
		global_position = ball.last_ball_holder.global_position + FREECAM_BUFFER
		target_zoom = ZOOM_DISTANCE
	zoom = zoom.move_toward(target_zoom, delta * 3)
	
	if Time.get_ticks_msec() - time_since_last_shake < DURATION_SHAKE and is_screen_shaking:
		offset = Vector2(randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY), randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY))
	else:
		is_screen_shaking = false
		offset = Vector2.ZERO

func on_impact_received(_impact_position: Vector2, is_high_intensity: bool) -> void:
	if is_high_intensity:
		is_screen_shaking = true
		time_since_last_shake = Time.get_ticks_msec()

func on_team_scored(_country_scored_on: String) -> void:
	is_on_freecam = true

func on_team_reset() -> void:
	is_on_freecam = false

func on_game_over() -> void:
	is_on_freecam = false
	global_position = ball.spawn_location
	target_zoom = Vector2.ONE
