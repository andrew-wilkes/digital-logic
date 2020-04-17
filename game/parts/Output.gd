extends Node2D

signal picked(node)
signal dropped
signal doubleclick

var state = false setget set_state
var active = false
var v_spacing = 32
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
		modulate = g.COLOR_HIGH
	else:
		modulate = g.COLOR_LOW


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.doubleclick:
			emit_signal("doubleclick")
		elif event.pressed:
			emit_signal("picked", self)
		else:
			emit_signal("dropped")


func _on_Area2D_mouse_entered():
	color = modulate
	if mode > 0:
		modulate = g.COLOR_ACTIVE


func _on_Area2D_mouse_exited():
	modulate = color
