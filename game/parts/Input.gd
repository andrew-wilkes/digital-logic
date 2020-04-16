extends Node2D

signal state_changed()
signal picked(node)
signal dropped

var state = false setget set_state
var id = 0
var active = false
var v_spacing = 56

func set_state(value):
	state = value
	if state:
		modulate = g.COLOR_HIGH
	else:
		modulate = g.COLOR_LOW
	emit_signal("state_changed")


func _on_TextureButton_button_down():
	if active:
		self.state = !state


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal("picked", self)
		else:
			emit_signal("dropped")


func _on_Area2D_mouse_entered():
	modulate = Color.green


func _on_Area2D_mouse_exited():
	modulate = Color.white
