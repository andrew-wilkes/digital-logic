extends Node2D

signal picked(node)
signal dropped

var state = false setget set_state
var active = false
var v_spacing = 32

func set_state(value):
	state = value
	if state:
		modulate = g.COLOR_HIGH
	else:
		modulate = g.COLOR_LOW


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
