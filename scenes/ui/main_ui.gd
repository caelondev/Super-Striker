class_name MainUI
extends Control

@onready var flag_texture : Array[TextureRect] = [%HomeFlag, %AwayFlag]
@onready var score_label : Label = %ScoreLabel
@onready var player_label : Label = %PlayerLabel
@onready var time_label : Label = %TimeLabel

func _init() -> void:
	GameEvents.ball_carried.connect(on_ball_carried.bind())
	GameEvents.ball_freeform.connect(on_ball_freeform.bind())

func _ready() -> void:
	update_score()
	update_flags()
	update_clock()
	player_label.text = ""

func _process(delta: float) -> void:
	update_clock()
	update_score()

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
