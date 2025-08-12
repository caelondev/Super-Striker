class_name ActorsContainer
extends Node2D

const PLAYER_SCENE := preload("res://scenes/characters/player.tscn")

@export var ball : Ball
@export var goal_home : Goal
@export var goal_away : Goal
@export var team_home : String
@export var team_away : String

@onready var home_spawner : Marker2D = %HomeSpawners
@onready var away_spawner : Marker2D = %AwaySpawners

func _ready():
	spawn_players(team_home, goal_home, home_spawner)
	spawn_players(team_away, goal_away, away_spawner)
	
	var player : Player = get_children().filter(func(p): return p is Player)[4]
	player.control_scheme = Player.ControlScheme.P1
	player.set_control_sprite()

func spawn_players(country: String, own_goal: Goal, spawner: Marker2D) -> void:
	var players := DataLoader.get_squad(country)
	var target_goal := goal_home if own_goal == goal_away else goal_away
	for i in players.size():
		var player_position := spawner.get_child(i).global_position as Vector2
		var player_data = players[i] as PlayerResources
		var player := spawn_player(player_position, ball, own_goal, target_goal, player_data, country)
		add_child(player)

func spawn_player(player_pos: Vector2, ctx_ball: Ball, own_goal: Goal, target_goal: Goal, player_data: PlayerResources, country: String) -> Player:
	var player := PLAYER_SCENE.instantiate()
	player.initialize(player_pos, ctx_ball, own_goal, target_goal, player_data, country)
	return player
