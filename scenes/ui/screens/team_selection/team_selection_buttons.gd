class_name TeamSelectionButtons
extends Control

@onready var arr_up := %ArrowUp
@onready var arr_down := %ArrowDown
@onready var arr_left := %ArrowLeft
@onready var arr_right := %ArrowRight

@export var left : String
@export var right : String
@export var up : String
@export var down : String

func _ready() -> void:
	arr_up.action = up
	arr_down.action = down
	arr_left.action = left
	arr_right.action = right
