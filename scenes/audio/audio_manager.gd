extends Node

enum Audio {BOUNCE, HURT, PASS, POWERSHOT, SHOT, TACKLING, UI_NAV, UI_SELECT, WHISTLE}

const AUDIO_CHANNELS := 5
const SFX_MAP : Dictionary[Audio, AudioStream] = {
	Audio.BOUNCE: preload("res://assets/sfx/bounce.wav"),
	Audio.HURT: preload("res://assets/sfx/hurt.wav"),
	Audio.PASS: preload("res://assets/sfx/pass.wav"),
	Audio.POWERSHOT: preload("res://assets/sfx/power-shot.wav"),
	Audio.SHOT: preload("res://assets/sfx/shoot.wav"),
	Audio.TACKLING: preload("res://assets/sfx/tackle.wav"),
	Audio.UI_NAV: preload("res://assets/sfx/ui-navigate.wav"),
	Audio.UI_SELECT: preload("res://assets/sfx/ui-select.wav"),
	Audio.WHISTLE: preload("res://assets/sfx/whistle.wav"),
}

var audio_streamers : Array[AudioStreamPlayer] = []

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func _ready() -> void:
	for audio_streamer in range(AUDIO_CHANNELS):
		var audio_player := AudioStreamPlayer.new()
		audio_streamers.append(audio_player)
		call_deferred("add_child", audio_player)

func play(audio: Audio) -> void:
	var stream_player := check_most_available_streamer()
	if stream_player != null:
		stream_player.stream = SFX_MAP[audio]
		stream_player.play()

func check_most_available_streamer() -> AudioStreamPlayer:
	for streamer in audio_streamers:
		if not streamer.playing:
			return streamer
	return null
