class_name PlayerState
extends Node

signal state_transition_requested(new_state: Player.State)

var animation_player : AnimationPlayer = null
var player : Player = null

func setup(context_player: Player, anim_player: AnimationPlayer) -> void:
	player = context_player
	animation_player = anim_player
