tool
extends Control

class_name GridInput

export var text = "A0" setget set_text, get_text

var state = false

func _ready():
	$Label.text = text


func set_text(t):
	if Engine.editor_hint and has_node("Label"):
		$Label.text = t
	text = t


func get_text():
	return text


func set_level(v: int):
	$Pin.self_modulate = g.get_state_color(v)
	state = bool(v)
