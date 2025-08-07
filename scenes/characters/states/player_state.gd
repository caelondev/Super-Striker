class_name PlayerState
extends Node

signal state_transition_requested(new_state: Player.State, player_state_data: PlayerStateData)

var animation_player : AnimationPlayer = null
var ball : Ball = null
var player : Player = null
var player_state_data: PlayerStateData = PlayerStateData.new()

func setup(context_player: Player, context_data: PlayerStateData, anim_player: AnimationPlayer, context_ball : Ball) -> void:
	player = context_player
	player_state_data = context_data
	animation_player = anim_player
	ball = context_ball

func transition_state(new_state : Player.State, player_state_data = PlayerStateData.new()) -> void:
	state_transition_requested.emit(new_state, player_state_data)

func animation_complete() -> void:
	pass
