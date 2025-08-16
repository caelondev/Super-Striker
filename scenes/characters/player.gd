class_name Player
extends CharacterBody2D

const CONTROL_HEIGHT_MAX := 30

const CONTROL_SCHEME_MAP : Dictionary = {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png"),
}
const COUNTRIES := ["NONE", "FRANCE", "ARGENTINA", "BRAZIL", "ENGLAND", "GERMANY", "ITALY", "SPAIN", "USA"]
const GRAVITY := 8.0

enum ControlScheme {CPU, P1, P2}
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
enum SkinColor {LIGHT, MEDIUM, DARK}
enum State {MOVING, TACKLING, RECOVERING, PASSING, PREP_SHOT, SHOOTING, HEADER, VOLLEY_KICK, BICYCLE_KICK, CHEST_CONTROL, HURT, DIVING}

@onready var ball_detection_area : Area2D = %BallDetectionArea
@onready var character_sprite : Sprite2D = $CharacterSprite
@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var control_sprite : Sprite2D = %ControlSprite
@onready var goalie_hands_collider : CollisionShape2D = %GoalieHandsCollider
@onready var permanent_damage_emitter_area : Area2D = %PermanentDamageEmitterArea
@onready var teammate_detection_area: Area2D = $TeammateDetectionArea
@onready var teammate_detection_ray : RayCast2D = %TeammateDetectionRay
@onready var tackle_damage_emitter : Area2D = %TackleDamageEmitter
@onready var opponent_detection_area : Area2D = %OpponentDetectionArea

@export var own_goal : Goal
@export var target_goal : Goal
@export var ball : Ball
@export var movement_speed : float = 80.0
@export var power : float
@export var control_scheme := ControlScheme.CPU

var ai_behavior_factory : AIBehaviorFactory = AIBehaviorFactory.new()
var country := "None"
var current_ai_behavior : AIBehavior = null
var current_state : PlayerState = null
var full_name := "PlayerName"
var heading := Vector2.RIGHT
var height := 0.0
var height_velocity := 0.0
var role := Player.Role.MIDFIELD
var skin_color := Player.SkinColor.MEDIUM
var queue_control := false
var spawn_position := Vector2.ZERO
var state_factory := PlayerStateFactory.new()
var weight_on_duty_stearing := 0.0

func _ready() -> void:
	setup_ai()
	switch_state(State.MOVING)
	set_control_sprite()
	set_shader_properties()
	goalie_hands_collider.disabled = role != Role.GOALIE
	permanent_damage_emitter_area.monitoring = role == Role.GOALIE
	tackle_damage_emitter.body_entered.connect(on_player_tackle.bind())
	permanent_damage_emitter_area.body_entered.connect(on_player_tackle.bind())
	spawn_position = global_position

func _physics_process(delta) -> void:
	set_control_visibility()
	process_gravity(delta)
	flip_char_sprite()
	handle_aim_rotation()
	move_and_slide()

func handle_aim_rotation() -> void:
	if velocity != Vector2.ZERO:
		teammate_detection_ray.rotation = velocity.angle()
		teammate_detection_area.rotation = velocity.angle()	

func setup_ai() -> void:
	current_ai_behavior = ai_behavior_factory.get_ai_behavior(role)
	current_ai_behavior.setup(self, ball, opponent_detection_area, teammate_detection_ray, teammate_detection_area)
	current_ai_behavior.name = "[AI] " + full_name + " (" + str(role) + ")"
	add_child(current_ai_behavior)

func set_shader_properties() -> void:
	character_sprite.material.set_shader_parameter("skin_color", skin_color)
	var country_color := COUNTRIES.find(country)
	country_color = clampi(country_color, 0, COUNTRIES.size() - 1)
	character_sprite.material.set_shader_parameter("team_color", country_color)

func initialize(c_position: Vector2, c_ball: Ball, c_own_goal: Goal, c_target_goal: Goal, c_player_data: PlayerResources, c_country: String) -> void:
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
	country = c_country

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
	current_state.setup(self, state_data,animation_player, ball, teammate_detection_ray, ball_detection_area, own_goal, target_goal, current_ai_behavior, tackle_damage_emitter, teammate_detection_area)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "PlayerState: " + str(state)
	call_deferred("add_child", current_state)

func handle_player_input() -> void: 
	var direction = KeyUtils.get_input_vector(control_scheme)
	velocity = direction.normalized() * movement_speed

func handle_animations() -> void:
	var vel_length := velocity.length()
	if vel_length < 1:
		animation_player.play("Idle")
	elif vel_length < movement_speed * 0.5:
		animation_player.play("Walk")
	else:
		animation_player.play("Run")

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
		tackle_damage_emitter.scale.x = 1
		opponent_detection_area.scale.x = 1
	elif heading == Vector2.LEFT:
		character_sprite.flip_h = true
		tackle_damage_emitter.scale.x = -1
		opponent_detection_area.scale.x = -1

func is_carrying_ball() -> bool:
	return ball.carrier == self

func animation_complete() -> void:
	if current_state != null:
		current_state.animation_complete()

func is_facing_target_goal() -> bool:
	var  direction_to_target_goal := global_position.direction_to(target_goal.global_position)
	return heading.dot(direction_to_target_goal) > 0

func control_ball() -> void:
	if ball.height > CONTROL_HEIGHT_MAX and height == 0:
		switch_state(State.CHEST_CONTROL)

func on_player_tackle(tackled_player: Player) -> void:
	if tackled_player != self and tackled_player.country != country and tackled_player == ball.carrier:
		tackled_player.stun_player(global_position.direction_to(tackled_player.global_position))

func can_carry_ball() -> bool:
	return current_state != null and current_state.can_carry_ball()

func stun_player(knockback_origin) -> void:
	switch_state(Player.State.HURT, PlayerStateData.build().set_hurt_direction(knockback_origin))

func send_pass_request(player: Player):
	if ball.carrier == self and current_state != null and current_state.can_pass():
		var data = PlayerStateData.build().set_pass_target(player)
		switch_state(Player.State.PASSING, data)
