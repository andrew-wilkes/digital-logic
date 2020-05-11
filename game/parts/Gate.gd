extends Part

class_name Gate

export(String) var gate_type

var inputs = []

func _ready():
	allow_testing()
	v_spacing = 72
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Inputs.get_children():
		node.hide_it()
		inputs.append(false)
		node.id = i
		connect_pin(node)
		i += 1
	connect_pin($Q)
	$Q.hide_it()
	$Q.is_output = true
	set_output(true)


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
	emit_signal("state_changed", self, output)


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
	output = result
