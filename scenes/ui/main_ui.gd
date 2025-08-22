class_name MainUI
extends Control

@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var flag_texture : Array[TextureRect] = [%HomeFlag, %AwayFlag]
@onready var goal_scorer_label: Label = %GoalScorerLabel
@onready var score_info_label : Label = %LeadLabel
@onready var score_label : Label = %ScoreLabel
@onready var player_label : Label = %PlayerLabel
@onready var time_label : Label = %TimeLabel

@export var ball : Ball

func _init() -> void:
	GameEvents.ball_carried.connect(on_ball_carried.bind())
	GameEvents.ball_freeform.connect(on_ball_freeform.bind())
	GameEvents.score_changed.connect(on_score_changed.bind())
	GameEvents.team_reset.connect(on_team_reset.bind())
	GameEvents.game_over.connect(on_game_over.bind())

func _ready() -> void:
	update_score()
	update_flags()
	update_clock()
	player_label.text = ""

func _process(delta: float) -> void:
	update_clock()

func update_flags() -> void:
	for i in flag_texture.size():
		flag_texture[i].texture = FlagHelper.get_texture(GameManager.countries[i])

func update_score() -> void:
	score_label.text = ScoreHelper.get_score_value(GameManager.score)

func update_clock() -> void:
	if GameManager.time_left < 0:
		time_label.modulate = Color.YELLOW
	else:
		time_label.modulate = Color.WHITE
	time_label.text = TimeHelper.get_time_value(GameManager.time_left)

func on_ball_carried(carrier_name: String) -> void:
	player_label.text = carrier_name

func on_ball_freeform() -> void:
	player_label.text = "FREEFORM"

func on_score_changed() -> void:
	if GameManager.is_times_up():
		return
	
	goal_scorer_label.text = "%s SCORED!" % [ball.last_ball_holder.full_name]
	score_info_label.text = ScoreHelper.get_current_score_info(GameManager.countries, GameManager.score)
	animation_player.play("GoalAppear")
	update_score()

func on_team_reset() -> void:
	if GameManager.has_someone_scored():
		animation_player.play("GoalHide")

func on_game_over(_winner: String) -> void:
	score_info_label.text = ScoreHelper.get_final_score_info(GameManager.countries, GameManager.score)
	animation_player.play("GameOver")
