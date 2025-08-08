class_name Ball
extends AnimatableBody2D

enum State {CARRIED, FREEFORM, SHOT}

@onready var animation_player = %AnimationPlayer
@onready var ball_sprite = %BallSprite
@onready var player_detection_area : Area2D = %PlayerDetectionArea

var carrier : Player = null
var current_state : BallState = null
var height := 0.0
var height_velocity := 0.0
var state_factory := BallStateFactory.new()
var velocity := Vector2.ZERO

func _ready():
	switch_state(State.FREEFORM)

func _physics_process(delta):
	ball_sprite.position = Vector2.UP * height

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
