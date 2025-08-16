class_name Ball
extends AnimatableBody2D

const PARABOLA_DISTANCE_TRESHOLD := 130
const TUMBLE_HEIGHT_VELOCITY := 10


enum State {CARRIED, FREEFORM, SHOT}

@export var BOUNCINESS := 0.8
@export var FRICTION_AIR := 35.0
@export var FRICTION_GROUND := 250.0

@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var ball_sprite : Sprite2D = %BallSprite
@onready var player_detection_area : Area2D = %PlayerDetectionArea
@onready var scoring_ray_cast : RayCast2D = %ScoringRayCast

var carrier : Player = null
var current_state : BallState = null
var height := 0.0
var height_velocity := 0.0
var spawn_location := Vector2.ZERO
var state_factory := BallStateFactory.new()
var velocity := Vector2.ZERO

func _ready():
	spawn_location = global_position
	switch_state(State.FREEFORM)

func _physics_process(delta):
	ball_sprite.position = Vector2.UP * height
	scoring_ray_cast.rotation = velocity.angle()

func switch_state(state: Ball.State) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, player_detection_area, carrier, animation_player, ball_sprite)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "BallStateMachine " + str(state)
	call_deferred("add_child", current_state)
func shoot(shot_velocity: Vector2) -> void:
	velocity = shot_velocity
	carrier = null
	switch_state(Ball.State.SHOT)

func tumble(tumble_velocity: Vector2) -> void:
	velocity = tumble_velocity
	carrier = null
	switch_state(Ball.State.FREEFORM)

func pass_to(destination: Vector2) -> void:
	var direction := position.direction_to(destination)
	var distance := position.distance_to(destination)
	var intensity := sqrt(2 * distance * FRICTION_GROUND)
	velocity = intensity * direction
	if distance >= PARABOLA_DISTANCE_TRESHOLD:
		height_velocity = BallState.GRAVITY * distance / (1.9 * intensity)
	carrier = null
	switch_state(Ball.State.FREEFORM)

func can_air_interact() -> bool:
	return current_state != null and current_state.can_air_interact()

func can_air_connect(AIR_CONNECT_MIN_HEIGHT: float, AIR_CONNECT_MAX_HEIGHT: float) -> bool:
	return height >= AIR_CONNECT_MIN_HEIGHT and height <= AIR_CONNECT_MAX_HEIGHT

func stop() -> void:
	velocity = Vector2.ZERO

func is_headed_for_scoring_area(scoring_area: Area2D) -> bool:
	if not scoring_ray_cast.is_colliding():
		return false
	return scoring_ray_cast.get_collider() == scoring_area
