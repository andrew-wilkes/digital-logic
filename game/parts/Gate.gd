extends Part

class_name Gate

export(String) var gate_type

var input_pin = preload("res://parts/zInput.tscn")
var output_pin = preload("res://parts/zOutput.tscn")
var inputs = []

func _ready():
	allow_testing()
	v_spacing = 72
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Inputs.get_children():
		pin_exit(node) # Hide
		inputs.append(false)
		if add_test_io: # When used in diagram
			var pin = input_pin.instance()
			pin.id = i
			pin.position = -pin.get_node("Q").position
			pin.highlight_pin = false
			pin.connect("state_changed", self, "update_output")
			node.add_child(pin)
		else:
			node.id = i
			connect_pin(node)
		i += 1
	pin_exit($Q) # Hide
	if add_test_io: # When used in diagram
		var pin = output_pin.instance()
		pin.position = -pin.get_node("Inputs/A").position
		pin.highlight_pin = false
		pin.highlight_part = false
		# warning-ignore:return_value_discarded
		connect("state_changed", pin, "update_output")
		$Q.add_child(pin)
	else:
		connect_pin($Q)
		$Q.is_output = true
	set_output(true)


func update_output(pin: Pin, state):
	# Only update on change of state
	if inputs[pin.id] == state and pin.was_connected_to:
		return
	if pin.state_changed():
		breakpoint
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
