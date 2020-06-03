extends Part

var inputs = []
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
		


func update_output(pin: Pin, state):
	# Only update on change of state
	if inputs[pin.id] == state and pin.was_connected_to:
		return
	pin.was_connected_to = true
	inputs[pin.id] = state
	$Pins.get_child(pin.id).modulate = g.get_state_color(state)
	$ProgressBar.value = decode_inputs()


func decode_inputs():
	var x = 0
	for i in range(3, -1, -1):
		x = x << 1
		if inputs[i]:
			x += 1
	return x
