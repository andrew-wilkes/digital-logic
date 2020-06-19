extends Part

enum { D, E }
enum { Q1, Q2}

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
	i = 0
	for node in $Outputs.get_children():
		node.id = i
		node.is_output = true
		connect_pin(node)
		i += 1
	outputs = [false, true]


func set_input(pin, state):
	if pin.state_changed():
		pinclick(pin)
		unstable()
		return
	inputs[pin.id] = state


func update_output(_pin, _state, _force = false):
	# Return if not enabled
	if inputs[E] == false or !_force:
		return
	if inputs[D] == outputs[Q2]:
		outputs[Q1] = inputs[D]
		outputs[Q2] = !inputs[D]
		emit_signals()


func emit_signals():
	for n in 2:
		emit_signal("state_changed", self, n, outputs[n])
