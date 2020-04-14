extends Node2D

signal state_changed()

var state = false setget set_state
var id = 0

func set_state(value):
	state = value
	if state:
		modulate = g.COLOR_HIGH
	else:
		modulate = g.COLOR_LOW
	emit_signal("state_changed")


func _on_TextureButton_button_down():
	self.state = !state
