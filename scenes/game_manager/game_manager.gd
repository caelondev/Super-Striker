extends Node

const DURATION_GAME := 2 * 60 * 1000

enum Stats {IN_PLAY, SCORED, RESET, KICKOFF, OVERTIME, GAMEOVER}

var countries : Array[String] = ["FRANCE", "USA"]
var score := [0, 0]
var time_left : float

func _ready() -> void:
	time_left = DURATION_GAME
