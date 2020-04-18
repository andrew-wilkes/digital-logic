extends Part

class_name Gate

export(String) var gate_type

var input_pin = preload("res://parts/zInput.tscn")
var output_pin = preload("res://parts/zOutput.tscn")
var inputs = []
var output

func _ready():
	v_spacing = 72
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Inputs.get_children():
		pin_exit(node) # Hide
		inputs.append(false)
		if mode == 0: # When used in diagram
			var pin = input_pin.instance()
			pin.mode = mode
			pin.id = i
			pin.connect("state_changed", self, "update_output", [pin])
			node.add_child(pin)
		else:
			node.id = i
			connect_pin(node)
		i += 1
	pin_exit($Q) # Hide
	if mode == 0: # When used in diagram
		output = output_pin.instance()
		output.mode = mode
		$Q.add_child(output)
	else:
		connect_pin($Q)
		$Q.is_output = true


func update_output(pin):
	inputs[pin.id] = pin.state
	var result = false
	match gate_type:
		"NOT":
			result = !pin.state
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
	output.state = result
