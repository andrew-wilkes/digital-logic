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
	update_output()


func set_input(pin, state):
	# Ignore if no change and the inital state was established after part was dropped from the palette
	if inputs[pin.id] == state and pin.was_connected_to:
		return
	if pin.state_changed(state):
		pinclick(pin) # Cause wire to be removed
		unstable()
		return
	pin.was_connected_to = true
	inputs[pin.id] = state


func update_output(force = false):
	# Only update on change of state
	var new_state = evaluate()
	if outputs[0] != new_state or force:
		outputs[0] = new_state
		emit_signal("state_changed", self, 0, new_state)


func evaluate():
	var result = false
	match gate_type:
		"NOT":
			result = !outputs[0]
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
	return result
