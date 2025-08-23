class_name TeamSelectionMenu
extends Control

const FLAG_ANCHOR_POINT := Vector2(70, 80)
const NB_COLS := 4
const NB_ROWS := 2

@onready var flags_container := %FlagsContainer

func _ready() -> void:
	place_flags()

func place_flags() -> void:
	for j in range(NB_ROWS):
		for i in range(NB_COLS):
			var flag_texture := TextureRect.new()
			var country_index := 1 + i + NB_COLS * j
			var country := DataLoader.get_countries()[country_index]
			flag_texture.texture = FlagHelper.get_texture(country)
			flag_texture.scale = Vector2.ONE * 2.3
			flag_texture.name = country.to_upper()
			flags_container.call_deferred("add_child", flag_texture)
			flag_texture.position = FLAG_ANCHOR_POINT + Vector2(55 * i, 50 * j) + Vector2.ONE
