extends Line2D

class_name Wire

var start_pin
var end_pin
var index = 0
var is_bus = false
var color

func delete():
	start_pin.wires.erase(self)
	if end_pin:
		end_pin.wires.erase(self)
	queue_free()


func highlight(do = true):
	if do:
		modulate = Color.black
	else:
		modulate = color


func set_color(state):
	if is_bus:
		color = g.COLOR_BUS
		width = 4
	else:
		if state:
			color = g.COLOR_HIGH
		else:
			color = g.COLOR_LOW
	modulate = color
