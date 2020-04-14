extends Node2D

var state = false setget set_state

func set_state(value):
	state = value
	if state:
		modulate = g.COLOR_HIGH
	else:
		modulate = g.COLOR_LOW
