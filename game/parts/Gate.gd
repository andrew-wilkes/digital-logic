extends Part

class_name Gate

export(String) var gate_type

var inputs = []
var labels = []

func _ready():
	allow_testing()
	v_spacing = 72
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for pin in $Inputs.get_children():
		pin.hide_it()
		inputs.append(false)
		pin.id = i
		connect_pin(pin)
		i += 1
	var pin = $Outputs.get_child(0)
	connect_pin(pin)
	pin.hide_it()
	pin.is_output = true
	outputs = [false]
	set_output(true)


func update_output(pin: Pin, state):
	# Only update on change of state
	if inputs[pin.id] == state and pin.was_connected_to:
		return
	if pin.state_changed():
		pinclick(pin)
		unstable()
		return
	pin.was_connected_to = true
	inputs[pin.id] = state
	set_output(state)
	emit_signal("state_changed", self, 0, outputs[0])


func set_output(state):
	var result = false
	match gate_type:
		"NOT":
			result = !state
		"OR", "NOR":
			for b in inputs:
				if b:
					result = b
		"AND", "NAND":
			result = true
			for b in inputs:
				if !b:
					result = false
		"XOR", "XNOR":
			result = inputs[0] != inputs[1]
		_:
			print("Gate type %s unknown!" % gate_type)
	match gate_type:
		"NOR", "NAND", "XNOR":
			result = !result
	outputs[0] = result
