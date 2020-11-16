tool
extends Control

export var txt = "Y0" setget set_text, get_text

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


func set_level(v: bool):
	if v:
		$OUT.self_modulate = g.COLOR_HIGH
	else:
		$OUT.self_modulate = g.COLOR_LOW
