extends Area2D

class_name Pin

var parent_part
var is_output = false
var wires = []
var id = 0
var was_connected_to = false
var updated = false

func state_changed():
	updated = !updated
	return !updated


func reset_state_changed():
	updated = false
