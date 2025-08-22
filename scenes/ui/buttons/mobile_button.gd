class_name MobileButton
extends Node2D

const DEFAULT_TEXTURE := "res://assets/art/ui/Double/Transparent center/panel-transparent-center-015.png"
const PRESSED_TEXTURE := "res://assets/art/ui/Double/Transparent center/panel-transparent-center-016.png"

@export var action : String
@export var icon_texture : Texture2D
@export var skill_cooldown : int

@onready var border_sprite := %Border
@onready var cooldown_label := %CooldownLabel
@onready var icon_sprite := %Icon
@onready var touchscreen_button := %TouchScreenButton

@export var is_on_cooldown := false

func _ready() -> void:
	icon_sprite.texture = icon_texture
	touchscreen_button.action = action

func _process(delta: float) -> void: 
	if not is_on_cooldown:
		touchscreen_button.visible = true
		border_sprite.modulate.a = 1
		icon_sprite.modulate.a = 1
	else:
		touchscreen_button.visible = false
		border_sprite.modulate.a = 0.5
		icon_sprite.modulate.a = 0.5


func _on_touch_screen_button_pressed() -> void:
	border_sprite.texture = load(PRESSED_TEXTURE)

func _on_touch_screen_button_released() -> void:
	border_sprite.texture = load(DEFAULT_TEXTURE)
