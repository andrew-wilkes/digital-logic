extends Line2D

class_name Wire

var start_pin
var end_pin
var index = 0
var is_bus = false

func delete():
	start_pin.wires.erase(self)
	if end_pin:
		end_pin.wires.erase(self)
	queue_free()


func set_color(state):
	if is_bus:
		modulate = g.COLOR_ACTIVE
	else:
		if state:
			modulate = g.COLOR_HIGH
		else:
			modulate = g.COLOR_LOW
