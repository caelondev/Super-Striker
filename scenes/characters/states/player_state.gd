class_name PlayerState
extends Node

signal state_transition_requested(new_state: Player.State, player_state_data: PlayerStateData)

var ai_behavior : AIBehavior = null
var animation_player : AnimationPlayer = null
var ball : Ball = null
var ball_detection_area : Area2D = null
var player : Player = null
var player_state_data: PlayerStateData = PlayerStateData.new()
var teammate_detection_area : Area2D = null
var own_goal : Goal = null
var target_goal

func setup(context_player: Player, context_data: PlayerStateData, anim_player: AnimationPlayer, context_ball : Ball, context_teammate_detection_area: Area2D, context_ball_detection_area: Area2D, context_own_goal: Goal, context_target_goal: Goal, context_ai_behavior: AIBehavior) -> void:
	player = context_player
	player_state_data = context_data
	animation_player = anim_player
	ball = context_ball
	ball_detection_area = context_ball_detection_area
	teammate_detection_area = context_teammate_detection_area
	target_goal = context_target_goal
	own_goal = context_own_goal
	ai_behavior = context_ai_behavior

func transition_state(new_state : Player.State, player_state_data = PlayerStateData.new()) -> void:
	state_transition_requested.emit(new_state, player_state_data)

func animation_complete() -> void:
	pass
