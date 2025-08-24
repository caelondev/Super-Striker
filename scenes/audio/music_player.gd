extends Node

enum Music { NONE, GAMEPLAY, MENU, TOURNAMENT, WIN }

const MUSIC_MAP: Dictionary = {
	Music.MENU: preload("res://assets/music/menu.mp3"),
	Music.TOURNAMENT: preload("res://assets/music/tournament.mp3"),
	Music.WIN: preload("res://assets/music/win.mp3"),
	Music.GAMEPLAY: preload("res://assets/music/gameplay.mp3"),
	
}

var current_music := Music.NONE
var playing_music: AudioStreamPlayer = null

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func play_music(music: Music) -> void:
	if music != current_music and MUSIC_MAP.has(music):
		if playing_music:
			playing_music.queue_free()

		playing_music = AudioStreamPlayer.new()
		
		var stream_copy = MUSIC_MAP[music].duplicate()
		stream_copy.loop = true
		
		playing_music.stream = stream_copy
		current_music = music

		add_child(playing_music)
		playing_music.play()
