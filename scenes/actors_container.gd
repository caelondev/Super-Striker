class_name ActorsContainer  
extends Node2D  
  
const SKILL_COOLDOWN_HANDLER := {  
	"shoot" : 0,  
	"pass" : 0,  
	"swap" : 5000,  
}  
const WEIGHT_CACHE_CALCULATION := 200  
const PLAYER_SCENE := preload("res://scenes/characters/player.tscn")  
const PLAYER_SWAP_COOLDOWN := 5000  
  
  
@onready var mobile_ui := $"../CanvasLayer/MobileUI"  
@export var ball : Ball  
@export var goal_home : Goal  
@export var goal_away : Goal
@export var two_player : bool  
  
@onready var home_spawner : Marker2D = %HomeSpawners  
@onready var away_spawner : Marker2D = %AwaySpawners
@onready var kickoff : Marker2D = %Kickoff

var is_checking_for_kickoff_readiness := false
var home_squad : Array[Player] = []  
var away_squad : Array[Player] = []  
var time_since_last_weight_cache := Time.get_ticks_msec()  
var time_since_p1_last_swap := Time.get_ticks_msec()  
var time_since_p2_last_swap := Time.get_ticks_msec()  
var player_one_index := 4  
var player_two_index := 10  
var player_1 : Player = null
var player_2 : Player = null
var team_home := GameManager.countries[0]
var team_away := GameManager.countries[1]

# Track previous cooldown states to avoid unnecessary signal emissions
var p1_swap_was_on_cooldown := false
var p2_swap_was_on_cooldown := false

func _ready():
	mobile_ui.has_two_players = two_player
	home_squad = spawn_players(team_home, goal_home, home_spawner)
	goal_home.initialize(team_home)
	kickoff.scale.x = -1
	goal_away.initialize(team_away)
	away_squad = spawn_players(team_away, goal_away, away_spawner)
	time_since_p1_last_swap = Time.get_ticks_msec() - SKILL_COOLDOWN_HANDLER["swap"]
	time_since_p2_last_swap = Time.get_ticks_msec() - SKILL_COOLDOWN_HANDLER["swap"]
	player_1 = create_player(player_one_index, Player.ControlScheme.P1)
	if two_player:
		player_2 = create_player(player_two_index, Player.ControlScheme.P2)
	GameEvents.team_reset.connect(on_team_reset.bind())

func create_player(role_index: int, control_scheme: Player.ControlScheme):  
	var player : Player = get_children().filter(func(p): return p is Player)[role_index - 1]  
	player.control_scheme = control_scheme  
	player.set_control_sprite()
	return player
  
func _physics_process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_last_weight_cache > WEIGHT_CACHE_CALCULATION:
		set_duty_weights()
	
	if is_checking_for_kickoff_readiness:
		check_for_kickoff_readiness()
	
	update_button_cooldowns()

func check_for_kickoff_readiness() -> void:
	for squad in [home_squad, away_squad]:
		for player : Player in squad:
			if not player.is_ready_for_kickoff():
				return
	GameEvents.kickoff_ready.emit()
	is_checking_for_kickoff_readiness = false

func on_team_reset() -> void:
	is_checking_for_kickoff_readiness = true

func update_button_cooldowns() -> void:
	# Check P1 swap cooldown
	var p1_time_left = get_cooldown_time_left(team_home, "swap")
	var p1_on_cooldown = p1_time_left > 0
	
	if p1_on_cooldown != p1_swap_was_on_cooldown:
		if p1_on_cooldown:
			mobile_ui.disable_button.emit("Swap", Player.ControlScheme.P1)
		else:
			mobile_ui.enable_button.emit("Swap", Player.ControlScheme.P1)
		p1_swap_was_on_cooldown = p1_on_cooldown
	
	# Update cooldown display for P1
	if p1_on_cooldown:
		mobile_ui.update_cooldown_display("Swap", Player.ControlScheme.P1, p1_time_left)
	
	# Check P2 swap cooldown if two player mode
	if two_player:
		var p2_time_left = get_cooldown_time_left(team_away, "swap")
		var p2_on_cooldown = p2_time_left > 0
		
		if p2_on_cooldown != p2_swap_was_on_cooldown:
			if p2_on_cooldown:
				mobile_ui.disable_button.emit("Swap", Player.ControlScheme.P2)
			else:
				mobile_ui.enable_button.emit("Swap", Player.ControlScheme.P2)
			p2_swap_was_on_cooldown = p2_on_cooldown
		
		# Update cooldown display for P2
		if p2_on_cooldown:
			mobile_ui.update_cooldown_display("Swap", Player.ControlScheme.P2, p2_time_left)

func get_cooldown_time_left(player_country: String, skill_name: String) -> int:
	match player_country:
		team_home:
			match skill_name:
				"swap":
					var time_passed = Time.get_ticks_msec() - time_since_p1_last_swap
					var time_left = SKILL_COOLDOWN_HANDLER["swap"] - time_passed
					return max(0, time_left)
		team_away:
			match skill_name:
				"swap":
					var time_passed = Time.get_ticks_msec() - time_since_p2_last_swap
					var time_left = SKILL_COOLDOWN_HANDLER["swap"] - time_passed
					return max(0, time_left)
	return 0

func is_team_skill_on_cd(player_country: String, skill_name: String) -> bool:  
	match player_country:  
		team_home:  
			match skill_name:  
				"swap":  
					var time_diff = Time.get_ticks_msec() - time_since_p1_last_swap
					var on_cooldown = time_diff < SKILL_COOLDOWN_HANDLER["swap"]
					return on_cooldown
		team_away:  
			match skill_name:  
				"swap":  
					var time_diff = Time.get_ticks_msec() - time_since_p2_last_swap
					var on_cooldown = time_diff < SKILL_COOLDOWN_HANDLER["swap"]
					return on_cooldown
	return false  
  
func refresh_cooldown(player_country: String, skill_name: String) -> void:  
	match player_country:  
		team_home:  
			match skill_name:  
				"swap":  
					time_since_p1_last_swap = Time.get_ticks_msec()
					# Immediately disable the button
					mobile_ui.disable_button.emit("Swap", Player.ControlScheme.P1)
					p1_swap_was_on_cooldown = true
		team_away:  
			match skill_name:  
				"swap":  
					time_since_p2_last_swap = Time.get_ticks_msec()
					# Immediately disable the button
					mobile_ui.disable_button.emit("Swap", Player.ControlScheme.P2)
					p2_swap_was_on_cooldown = true
  
func spawn_players(country: String, own_goal: Goal, spawner: Marker2D) -> Array[Player]:  
	var player_squad : Array[Player] = []  
	var players := DataLoader.get_squad(country)  
	var target_goal := goal_home if own_goal == goal_away else goal_away  
	for i in players.size():  
		var player_position := spawner.get_child(i).global_position as Vector2  
		var player_data = players[i] as PlayerResources
		var kickoff_position := player_position
		if i > 3:
			kickoff_position = kickoff.get_child(i-4).global_position as Vector2
		var player := spawn_player(player_position, ball, own_goal, target_goal, player_data, country, kickoff_position)  
		player_squad.append(player)  
		add_child(player)  
	return player_squad  
  
func spawn_player(player_pos: Vector2, ctx_ball: Ball, own_goal: Goal, target_goal: Goal, player_data: PlayerResources, country: String, kickoff_position: Vector2) -> Player:  
	var player := PLAYER_SCENE.instantiate()  
	player.initialize(player_pos, ctx_ball, own_goal, target_goal, player_data, country, kickoff_position)  
	player.swap_control_scheme_request.connect(on_player_swap_request.bind())  
	return player  
  
func set_duty_weights() -> void:  
	if Time.get_ticks_msec() - time_since_last_weight_cache < WEIGHT_CACHE_CALCULATION:  
		return  
	time_since_last_weight_cache = Time.get_ticks_msec()  
	  
	for squad in [away_squad, home_squad]:  
		var cpu_players : Array[Player] = squad.filter(  
			func(p: Player): return p.control_scheme == Player.ControlScheme.CPU and p.role != Player.Role.GOALIE  
		)  
		cpu_players.sort_custom(func(p1: Player, p2: Player):  
			return p1.spawn_position.distance_squared_to(ball.global_position) < p2.spawn_position.distance_squared_to(ball.global_position))  
		for i in range(cpu_players.size()):  
			cpu_players[i].weight_on_duty_stearing = 1 - ease(float(i)/10.0, 0.1)  
  
func on_player_swap_request(requester: Player) -> void:  
	if is_team_skill_on_cd(requester.country, "swap"):  
		return  
	  
	var squad := home_squad if home_squad.has(requester) else away_squad  
  
	var cpu_players: Array[Player] = squad.filter(  
		func(p: Player) -> bool:  
			return p.control_scheme == Player.ControlScheme.CPU and p.role != Player.Role.GOALIE  
	)  
	if cpu_players.is_empty():  
		return  
  
	cpu_players.sort_custom(func(a: Player, b: Player) -> bool:  
		return a.global_position.distance_squared_to(ball.global_position) < b.global_position.distance_squared_to(ball.global_position)  
	)  
	var closest_cpu_to_ball: Player = cpu_players[0]  
	var controlled_player: Player = requester  
  
	var d_cpu := closest_cpu_to_ball.global_position.distance_squared_to(ball.global_position)  
	var d_ctrl := controlled_player.global_position.distance_squared_to(ball.global_position)  
  
	if d_cpu < d_ctrl:  
		var scheme := controlled_player.control_scheme  
		controlled_player.control_scheme = Player.ControlScheme.CPU  
		controlled_player.set_control_sprite()  
		closest_cpu_to_ball.control_scheme = scheme  
		closest_cpu_to_ball.set_control_sprite()  
		refresh_cooldown(requester.country, "swap")
