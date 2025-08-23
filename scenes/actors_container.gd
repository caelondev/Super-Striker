class_name ActorsContainer      
extends Node2D      
	  
const SKILL_COOLDOWN_HANDLER := {      
	"shoot" : 0,      
	"pass" : 0,      
	"swap" : 5000,      
}      
const WEIGHT_CACHE_CALCULATION := 200      
const PLAYER_SCENE := preload("res://scenes/characters/player.tscn")      
const SPARK_SCENE := preload("res://scenes/sparks/spark.tscn")    
const PLAYER_SWAP_COOLDOWN := 5000      
	  
	  
@onready var mobile_ui := %MobileUI    
@export var ball : Ball      
@export var goal_home : Goal      
@export var goal_away : Goal    
@export var two_player : bool      
	  
@onready var home_spawner : Marker2D = %HomeSpawners      
@onready var away_spawner : Marker2D = %AwaySpawners    
@onready var kickoff : Marker2D = %Kickoff    
	
var home_squad : Array[Player] = []      
var away_squad : Array[Player] = []      
var time_since_last_weight_cache := Time.get_ticks_msec()      

# Individual player cooldown tracking instead of team-based
var time_since_player1_last_swap := 0
var time_since_player2_last_swap := 0

var player_1 : Player = null    
var player_2 : Player = null    
var team_home := GameManager.countries[0]    
var team_away := GameManager.countries[1]    
	
var p1_swap_was_on_cooldown := false    
var p2_swap_was_on_cooldown := false    
	
func _init() -> void:    
	GameEvents.team_reset.connect(on_team_reset.bind())    
	GameEvents.impact_received.connect(on_impact_received.bind())    
	
func _ready():    
	mobile_ui.has_two_players = two_player    
	home_squad = spawn_players(team_home, goal_home, home_spawner)    
	goal_home.initialize(team_home)    
	kickoff.scale.x = -1    
	goal_away.initialize(team_away)    
	away_squad = spawn_players(team_away, goal_away, away_spawner)    
	
	# Initialize individual player cooldowns (both start ready to use)
	var current_time = Time.get_ticks_msec()
	time_since_player1_last_swap = current_time - SKILL_COOLDOWN_HANDLER["swap"]
	time_since_player2_last_swap = current_time - SKILL_COOLDOWN_HANDLER["swap"]
	
	setup_control_scheme()    
	  
func _physics_process(_delta: float) -> void:    
	if Time.get_ticks_msec() - time_since_last_weight_cache > WEIGHT_CACHE_CALCULATION:    
		set_duty_weights()    
	update_button_cooldowns()    
	
func update_button_cooldowns() -> void:    
	# Handle Player 1 cooldown
	var p1_time_left = get_cooldown_time_left_for_player(Player.ControlScheme.P1)
	var p1_on_cooldown = p1_time_left > 0
	
	if p1_on_cooldown != p1_swap_was_on_cooldown:
		if p1_on_cooldown:
			mobile_ui.disable_button.emit("Swap", Player.ControlScheme.P1)
		else:
			mobile_ui.enable_button.emit("Swap", Player.ControlScheme.P1)
		p1_swap_was_on_cooldown = p1_on_cooldown
	
	if p1_on_cooldown:
		mobile_ui.update_cooldown_display("Swap", Player.ControlScheme.P1, p1_time_left)
	
	# Handle Player 2 cooldown if Player 2 exists
	if not GameManager.player_setup[1].is_empty():
		var p2_time_left = get_cooldown_time_left_for_player(Player.ControlScheme.P2)
		var p2_on_cooldown = p2_time_left > 0
		
		if p2_on_cooldown != p2_swap_was_on_cooldown:
			if p2_on_cooldown:
				mobile_ui.disable_button.emit("Swap", Player.ControlScheme.P2)
			else:
				mobile_ui.enable_button.emit("Swap", Player.ControlScheme.P2)
			p2_swap_was_on_cooldown = p2_on_cooldown
		
		if p2_on_cooldown:
			mobile_ui.update_cooldown_display("Swap", Player.ControlScheme.P2, p2_time_left)

# Individual player cooldown functions
func get_cooldown_time_left_for_player(control_scheme: Player.ControlScheme) -> int:
	var time_passed: int
	match control_scheme:
		Player.ControlScheme.P1:
			time_passed = Time.get_ticks_msec() - time_since_player1_last_swap
		Player.ControlScheme.P2:
			time_passed = Time.get_ticks_msec() - time_since_player2_last_swap
		_:
			return 0
	
	var time_left = SKILL_COOLDOWN_HANDLER["swap"] - time_passed
	return max(0, time_left)

func is_player_skill_on_cd(control_scheme: Player.ControlScheme) -> bool:
	return get_cooldown_time_left_for_player(control_scheme) > 0

func refresh_cooldown_for_player(control_scheme: Player.ControlScheme) -> void:
	match control_scheme:
		Player.ControlScheme.P1:
			time_since_player1_last_swap = Time.get_ticks_msec()
			mobile_ui.disable_button.emit("Swap", Player.ControlScheme.P1)
			p1_swap_was_on_cooldown = true
		Player.ControlScheme.P2:
			time_since_player2_last_swap = Time.get_ticks_msec()
			mobile_ui.disable_button.emit("Swap", Player.ControlScheme.P2)
			p2_swap_was_on_cooldown = true

# Legacy functions kept for compatibility (these are no longer used)
func get_cooldown_time_left(player_country: String, skill_name: String) -> int:    
	# This function is kept for compatibility but no longer used
	return 0
	
func is_team_skill_on_cd(player_country: String, skill_name: String) -> bool:      
	# This function is kept for compatibility but no longer used
	return false
	  
func refresh_cooldown(player_country: String, skill_name: String) -> void:      
	# This function is kept for compatibility but no longer used
	pass
	  
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
	# Check cooldown based on the requester's control scheme instead of country
	if is_player_skill_on_cd(requester.control_scheme):
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
		controlled_player.set_control_scheme(Player.ControlScheme.CPU)    
		if scheme == Player.ControlScheme.P1:    
			player_1 = closest_cpu_to_ball.set_control_scheme(scheme)    
		elif scheme == Player.ControlScheme.P2:    
			player_2 = closest_cpu_to_ball.set_control_scheme(scheme)    
		
		# Apply cooldown to the specific player who requested the swap
		refresh_cooldown_for_player(scheme)
	
func setup_control_scheme() -> void:    
	var p1_team := home_squad if GameManager.player_setup[0] == home_squad[0].country else away_squad    
	var p2_team := away_squad if p1_team == home_squad else home_squad    
		
	for team in [home_squad, away_squad]:    
		for player : Player in team:    
			player.set_control_scheme(Player.ControlScheme.CPU)    
		
	if GameManager.is_coop():    
		player_1 = p1_team[4].set_control_scheme(Player.ControlScheme.P1)    
		player_2 = p1_team[5].set_control_scheme(Player.ControlScheme.P2)    
	elif GameManager.is_single_player():    
		player_1 =p1_team[3].set_control_scheme(Player.ControlScheme.P1)    
	else:    
		player_1 = p1_team[3].set_control_scheme(Player.ControlScheme.P1)    
		player_2 = p2_team[3].set_control_scheme(Player.ControlScheme.P2)    
	
func on_team_reset() -> void:    
	setup_control_scheme()    
	
func on_impact_received(impact_position: Vector2, _is_high_impact: bool) -> void:    
	var spark := SPARK_SCENE.instantiate()    
	spark.global_position = impact_position    
	call_deferred("add_child", spark)
