class_name Goal
extends Node2D

@onready var backnet_area := %BacknetArea

func _ready():
	backnet_area.body_entered.connect(on_ball_enter_backnet.bind())

func on_ball_enter_backnet(ball: Ball) -> void:
	ball.stop()
