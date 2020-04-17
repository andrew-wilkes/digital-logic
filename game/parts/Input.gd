extends Node2D

signal state_changed()
signal picked(node)
signal dropped

var state = false setget set_state
var active = false
var id = 0
var v_spacing = 56
export(int) var mode = 1
var color

func _ready():
	color = g.COLOR_UNDEFINED
	modulate = color
	# Bring into view when testing scene in isolation
	if get_parent().name == "root":
		position = Vector2(100, 100)


func set_state(value):
	state = value
	if state:
		color = g.COLOR_HIGH
	else:
		color = g.COLOR_LOW
	modulate = color
	emit_signal("state_changed")


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if mode == 0:
				self.state = !state
			emit_signal("picked", self)
		else:
			mode = 0
			emit_signal("dropped")


func _on_Area2D_mouse_entered():
	color = modulate
	modulate = Color.green


func _on_Area2D_mouse_exited():
	modulate = color
