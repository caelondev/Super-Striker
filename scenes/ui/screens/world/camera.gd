class_name Camera
extends Camera2D

signal zooming_completed()

const DISTANCE_TARGET := 100
const DURATION_SHAKE := 100
const SHAKE_INTENSITY := 5
const SMOOTHING_BALL_CARRIED = 1.5
const SMOOTHING_BALL_DEFAULT = 5
const ZOOM_DISTANCE := Vector2.ONE * 1.3
const POWERSHOT_HIGHLIGHT_ZOOM := Vector2.ONE * 1.8
const FREECAM_BUFFER := Vector2.DOWN * 15

@onready var mobile_ui := %MobileUI

@export var ball : Ball

var distance_to_player := Vector2.ZERO
var is_powershot_used := false
var is_screen_shaking := false
var time_since_last_shake := Time.get_ticks_msec()
var is_on_freecam := false
var target_zoom := Vector2.ONE
var player : Player = null

var highlight_timer := 0.0
const HIGHLIGHT_DURATION := 0.6

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func _ready() -> void:
	GameEvents.released_powershot.connect(on_player_used_powershot.bind())
	GameEvents.impact_received.connect(on_impact_received.bind())
	GameEvents.team_scored.connect(on_team_scored.bind())
	GameEvents.game_over.connect(on_game_over.bind())
	GameEvents.team_reset.connect(on_team_reset.bind())
	zooming_completed.connect(on_zoom_complete.bind())

func _physics_process(delta):
	if not is_on_freecam:
		target_zoom = Vector2.ONE
		if ball.carrier != null:
			distance_to_player = global_position.direction_to(ball.carrier.global_position)
			position_smoothing_speed = SMOOTHING_BALL_CARRIED
			global_position = ball.carrier.global_position + ball.carrier.heading * DISTANCE_TARGET
		else:
			position_smoothing_speed = SMOOTHING_BALL_DEFAULT
			global_position = ball.global_position
		if is_powershot_used and player != null:
			distance_to_player = global_position.direction_to(player.global_position)
			ball.z_index = 1
			target_zoom = POWERSHOT_HIGHLIGHT_ZOOM
			global_position = player.global_position
			highlight_timer -= delta
			zooming_completed.emit()
			if highlight_timer <= 0.0:
				is_powershot_used = false
				player = null
				ball.z_index = 0
	else:
		global_position = ball.last_ball_holder.global_position + FREECAM_BUFFER
		target_zoom = ZOOM_DISTANCE
	
	zoom = zoom.move_toward(target_zoom, delta * sqrt(distance_to_player.length()))
	
	if Time.get_ticks_msec() - time_since_last_shake < DURATION_SHAKE and is_screen_shaking:
		offset = Vector2(
			randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY),
			randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY)
		)
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

func on_player_used_powershot(c_player: Player) -> void:
	player = c_player
	is_powershot_used = true
	highlight_timer = HIGHLIGHT_DURATION

func on_zoom_complete() -> void:
	mobile_ui.visible = zoom == Vector2.ONE 
