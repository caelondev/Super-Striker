class_name Player
extends CharacterBody2D

const CONTROL_HEIGHT_MAX := 30

const CONTROL_SCHEME_MAP : Dictionary = {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png"),
}
const GRAVITY := 8.0

enum ControlScheme {CPU, P1, P2}
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
enum SkinColor {LIGHT, MEDIUM, DARK}
enum State {MOVING, TACKLING, RECOVERING, PASSING, PREP_SHOT, SHOOTING, HEADER, VOLLEY_KICK, BICYCLE_KICK, CHEST_CONTROL}

@onready var ball_detection_area : Area2D = %BallDetectionArea
@onready var character_sprite : Sprite2D = $CharacterSprite
@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var control_sprite : Sprite2D = %ControlSprite
@onready var teammate_detection_area : Area2D = %TeammateDetectionArea

@export var own_goal : Goal
@export var target_goal : Goal
@export var ball : Ball
@export var movement_speed : float = 80.0
@export var power : float
@export var control_scheme := ControlScheme.CPU

var current_state : PlayerState = null
var full_name := "PlayerName"
var heading := Vector2.RIGHT
var height := 0.0
var height_velocity := 0.0
var role := Player.Role.MIDFIELD
var skin_color := Player.SkinColor.MEDIUM
var queue_control := false
var state_factory := PlayerStateFactory.new()

func _ready() -> void:
	switch_state(State.MOVING)
	set_control_sprite()

func _physics_process(delta) -> void:
	set_control_visibility()
	process_gravity(delta)
	flip_char_sprite()
	move_and_slide()

func initialize(c_position: Vector2, c_ball: Ball, c_own_goal: Goal, c_target_goal: Goal, c_player_data: PlayerResources) -> void:
	position = c_position
	ball = c_ball
	own_goal = c_own_goal
	target_goal = c_target_goal
	movement_speed = c_player_data.speed
	power = c_player_data.power
	role = c_player_data.role
	full_name = c_player_data.full_name
	name = full_name
	skin_color = c_player_data.skin_color
	heading = Vector2.LEFT if target_goal.global_position.x < global_position.x else Vector2.RIGHT

func process_gravity(delta: float) -> void:
	if height > 0:
		height_velocity -= GRAVITY * delta
		height += height_velocity
		if height <= 0:
			height = 0
	character_sprite.position = Vector2.UP * height

func set_control_visibility() -> void:
	control_sprite.visible = is_carrying_ball() or not control_scheme == ControlScheme.CPU

func switch_state(state: State, state_data: PlayerStateData = PlayerStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	
	current_state = state_factory.get_fresh_tates(state)
	current_state.setup(self, state_data,animation_player, ball, teammate_detection_area, ball_detection_area, own_goal, target_goal)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "PlayerState: " + str(state)
	call_deferred("add_child", current_state)

func handle_player_input() -> void: 
	var direction = KeyUtils.get_input_vector(control_scheme)
	velocity = direction.normalized() * movement_speed

func handle_animations() -> void:
	if velocity.length() > 0:
		animation_player.play("Run")
	else:
		animation_player.play("Idle")

func set_control_sprite() -> void:
	control_sprite.texture = CONTROL_SCHEME_MAP[control_scheme]

func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func flip_char_sprite() -> void:
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
	elif heading == Vector2.LEFT:
		character_sprite.flip_h = true

func is_carrying_ball() -> bool:
	return ball.carrier == self

func animation_complete() -> void:
	if current_state != null:
		current_state.animation_complete()

func control_ball() -> void:
	if ball.height > CONTROL_HEIGHT_MAX and height == 0:
		switch_state(State.CHEST_CONTROL)
