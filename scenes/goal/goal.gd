class_name Goal
extends Node2D

@onready var backnet_area : Area2D = %BacknetArea
@onready var scoring_area : Area2D = %ScoringArea
@onready var targets : Node2D = %Targets

var country := ""

func _ready():
	backnet_area.body_entered.connect(on_ball_enter_backnet.bind())
	scoring_area.body_entered.connect(on_ball_enter_scoring_area.bind())

func initialize(ctx_country: String) -> void:
	country = ctx_country


func on_ball_enter_scoring_area(_ball: Ball) -> void:
	GameEvents.team_scored.emit(country)

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

func get_scoring_area() -> Area2D:
	return scoring_area
