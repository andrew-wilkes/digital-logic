extends Line2D

class_name Wire

var start_pin
var end_pin
var index = 0

func delete():
	start_pin.wires.erase(self)
	if end_pin:
		end_pin.wires.erase(self)
	queue_free()


func set_color(state):
		if state:
			modulate = g.COLOR_HIGH
		else:
			modulate = g.COLOR_LOW
