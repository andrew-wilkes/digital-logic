tool
extends Control

class_name GridInput

export var txt = "A0" setget set_text, get_text

export var text: String

func _ready():
	$Label.text = text


func set_text(t):
	if Engine.editor_hint and has_node("Label"):
		$Label.text = t
		text = t
		property_list_changed_notify()


func get_text():
	return text


func set_level(v: int):
	$Pin.self_modulate = g.get_state_color(v)
