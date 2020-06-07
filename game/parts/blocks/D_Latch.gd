extends Part

var inputs = []
var labels =  ["D","E","+Q","-Q"]

func _ready():
	allow_testing()
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for pin in $Inputs.get_children():
		inputs.append(false)
		pin.id = i
		connect_pin(pin)
		i += 1
	for node in $Outputs.get_children():
		node.id = i
		node.is_output = true
		connect_pin(node)
		i += 1
	outputs = [false, true]


func update_output(pin: Pin, state):
	# Only update on change of state
	if inputs[pin.id] == state and pin.was_connected_to:
		return
	if pin.state_changed():
		pin.wires[0].delete()
		unstable()
		return
	pin.was_connected_to = true
	inputs[pin.id] = state
	set_output(state)
	emit_signal("state_changed", self, 0, outputs[0])


func set_output(state):
	var result = false
	outputs[0] = result
