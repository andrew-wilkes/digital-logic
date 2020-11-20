tool
extends Control

class_name Grid_Output

export var txt = "Y0" setget set_text, get_text

export var text: String

var inputs = {}
var state = false

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
	$Pin.self_modulate = g.get_state_color(v)
	state = v


func set_result(v: bool):
	$Label.self_modulate = g.COLOR_RIGHT if v else g.COLOR_WRONG
