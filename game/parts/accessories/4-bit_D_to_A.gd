extends Part

var labels =  ["I0","I1","I2","I3"]

func _ready():
	allow_testing()
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Inputs.get_children():
		inputs.append(false)
		node.id = i
		connect_pin(node)
		i += 1


func update_output(pin, state, _force = false):
	$Pins.get_child(pin.id).modulate = g.get_state_color(state)
	$ProgressBar.value = g.decode_inputs(inputs)
