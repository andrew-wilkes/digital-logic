extends Part

func _ready():
	labels =  ["I0","I1","I2","I3"]


func update_output(pin, state):
	$Pins.get_child(pin.id).modulate = g.get_state_color(state)
	$ProgressBar.value = g.decode_inputs(inputs)
