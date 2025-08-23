class_name FlagSelector
extends Control

signal selected

@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var p1_indicator : TextureRect = %Indicator1P
@onready var p2_indicator : TextureRect = %Indicator2P

var control_scheme : Player.ControlScheme = Player.ControlScheme.P1
var is_selected := false

func _ready() -> void:
	p1_indicator.visible = control_scheme == Player.ControlScheme.P1
	p2_indicator.visible = control_scheme == Player.ControlScheme.P2

func _process(delta: float) -> void:
	if KeyUtils.get_actions_just_pressed(control_scheme, KeyUtils.Action.SHOOT):
		is_selected = not is_selected
		if is_selected:
			animation_player.play("Selected")
			selected.emit()
			AudioManager.play(AudioManager.Audio.UI_SELECT)
		else:
			animation_player.play("Selecting")
