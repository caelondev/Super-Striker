class_name BallStateData
extends Node

var lock_duration : int

static func build() -> BallStateData:
	return BallStateData.new()

func set_lock_duraion(duration: int) -> BallStateData:
	lock_duration = duration
	return self
