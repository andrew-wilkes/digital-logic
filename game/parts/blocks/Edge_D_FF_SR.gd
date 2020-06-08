extends Part

enum { D, CLK, S, R }
enum { QP, QN}

var inputs = []
var labels =  ["D","CLK","+Q","-Q"]
var q1 = false

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
		pin.wires[0].delete()
		unstable()
		return
	pin.was_connected_to = true
	inputs[pin.id] = state
	if pin.id == S and inputs[S] and outputs[QN]:
		q1 = true
		set_outputs()
		return
	if pin.id == R and inputs[R] and outputs[QP]:
		q1 = false
		set_outputs()
		return
	if inputs[CLK] == false:
		q1 = inputs[D] # Store D in the first latch 
	elif pin.id == CLK and outputs[QP] != q1: # q1 has changed and the clk has gone low > high 
		set_outputs()


func set_outputs():
		outputs[QP] = q1
		outputs[QN] = !q1
		emit_signal("new_event")
		for n in 2:
			emit_signal("state_changed", self, n, outputs[n])
