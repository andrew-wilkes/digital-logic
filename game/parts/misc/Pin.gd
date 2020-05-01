extends Area2D

class_name Pin

var parent_part
var is_output = false
var wires = []
var id = 0
var was_connected_to = false
var updated = 0

func state_changed():
	updated += 1
	return updated > g.UNSTABLE_THRESHOLD


func reset_state_changed():
	updated = 0
