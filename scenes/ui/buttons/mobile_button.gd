class_name MobileButton
extends Node2D

@export var action : String
@export var icon_texture : Texture2D
@export var skill_cooldown : int

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
		icon_sprite.modulate.a = 1
	else:
		touchscreen_button.visible = false
		icon_sprite.modulate.a = 0.5
