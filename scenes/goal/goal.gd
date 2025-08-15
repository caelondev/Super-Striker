class_name Goal
extends Node2D

@onready var backnet_area : Area2D = %BacknetArea
@onready var ball_detection_area : Area2D = %BallDetectionArea
@onready var targets : Node2D = %Targets

var ball_entered := false
var ball : Ball = null

func _ready():
	ball_detection_area.body_entered.connect(on_ball_score.bind())
	backnet_area.body_entered.connect(on_ball_enter_backnet.bind())

func _physics_process(delta: float) -> void:
	if ball != null and ball_entered:
		if ball.velocity == Vector2.ZERO and ball.height == 0:
			ball.global_position = ball.spawn_location

func on_ball_score(context_ball: Ball) -> void:
	ball_entered = true
	ball = context_ball

func on_ball_enter_backnet(ball: Ball) -> void:
	ball.stop()

func get_random_target_position() -> Vector2:
	if targets and targets.get_child_count() > 0:
		var index = randi_range(0, targets.get_child_count() - 1)
		var target = targets.get_child(index)
		if target:
			return target.global_position
	return Vector2.ZERO

func get_goal_point(index: int) -> Vector2:
	return targets.get_child(index-1).global_position
