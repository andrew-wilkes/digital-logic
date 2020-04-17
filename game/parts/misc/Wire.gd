extends Line2D

var start_pin
var end_pin

func delete():
	start_pin.wires.erase(self)
	end_pin.wires.erase(self)
	queue_free()
