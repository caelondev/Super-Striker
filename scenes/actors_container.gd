class_name ActorsContainer
extends Node2D

const WEIGHT_CACHE_CALCULATION := 200
const PLAYER_SCENE := preload("res://scenes/characters/player.tscn")


@onready var mobile_ui := $"../CanvasLayer/MobileUI"

@export var ball : Ball
@export var goal_home : Goal
@export var goal_away : Goal
@export var team_home : String
@export var team_away : String
@export var two_player : bool

@onready var home_spawner : Marker2D = %HomeSpawners
@onready var away_spawner : Marker2D = %AwaySpawners

var home_squad : Array[Player] = []
var away_squad : Array[Player] = []
var time_sincs_last_weight_cache := Time.get_ticks_msec()
var player_one_index := 4
var player_two_index := 10

func _ready():
	mobile_ui.has_two_players = two_player
	home_squad = spawn_players(team_home, goal_home, home_spawner)
	away_squad = spawn_players(team_away, goal_away, away_spawner)
	
	create_player(player_one_index, Player.ControlScheme.P1)
	if two_player:
		create_player(player_two_index, Player.ControlScheme.P2)

func create_player(role_index: int, control_scheme: Player.ControlScheme):
	var player : Player = get_children().filter(func(p): return p is Player)[role_index - 1]
	player.control_scheme = control_scheme
	player.set_control_sprite()

func _physics_process(_delta: float) -> void:
	set_duty_weights()

func spawn_players(country: String, own_goal: Goal, spawner: Marker2D) -> Array[Player]:
	var player_squad : Array[Player] = []
	var players := DataLoader.get_squad(country)
	var target_goal := goal_home if own_goal == goal_away else goal_away
	for i in players.size():
		var player_position := spawner.get_child(i).global_position as Vector2
		var player_data = players[i] as PlayerResources
		var player := spawn_player(player_position, ball, own_goal, target_goal, player_data, country)
		player_squad.append(player)
		add_child(player)
	return player_squad

func spawn_player(player_pos: Vector2, ctx_ball: Ball, own_goal: Goal, target_goal: Goal, player_data: PlayerResources, country: String) -> Player:
	var player := PLAYER_SCENE.instantiate()
	player.initialize(player_pos, ctx_ball, own_goal, target_goal, player_data, country)
	return player

func set_duty_weights() -> void:
	if Time.get_ticks_msec() - time_sincs_last_weight_cache < WEIGHT_CACHE_CALCULATION:
		return
	time_sincs_last_weight_cache = Time.get_ticks_msec()
	
	for squad in [away_squad, home_squad]:
		var cpu_players : Array[Player] = squad.filter(
			func(p: Player): return p.control_scheme == Player.ControlScheme.CPU and p.role != Player.Role.GOALIE
		)
		cpu_players.sort_custom(func(p1: Player, p2: Player):
			return p1.spawn_position.distance_squared_to(ball.global_position) < p2.spawn_position.distance_squared_to(ball.global_position))
		for i in range(cpu_players.size()):
			cpu_players[i].weight_on_duty_stearing = 1 - ease(float(i)/10.0, 0.1)
