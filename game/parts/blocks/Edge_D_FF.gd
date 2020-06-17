extends Part

enum { D, CLK }
enum { QP, QN}

var inputs = []
var labels =  ["D","CLK","+Q","-Q"]

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


func update_output(pin: Pin, state):
	# Only update on change of state
	if inputs[pin.id] == state and pin.was_connected_to:
		return
	if pin.state_changed():
		pinclick(pin)
		unstable()
		return
	inputs[pin.id] = state
	if !pin.was_connected_to:
		pin.was_connected_to = true
		emit_signals()
	if outputs[QP]:
		if pin.id == CLK and state and inputs[D] == false:
			set_outputs(false)
	else:
		if pin.id == CLK and state and inputs[D] == true:
			set_outputs(true)

func set_outputs(v):
		outputs[QP] = v
		outputs[QN] = !v
		emit_signals()


func emit_signals():
	for n in 2:
		emit_signal("state_changed", self, n, outputs[n])