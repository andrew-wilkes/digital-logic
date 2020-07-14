extends Part

class_name Gate

export(String) var gate_type

func _ready():
	for pin in $Inputs.get_children():
		pin.hide_it()
	$Outputs.get_child(0).hide_it()


func update_output(_pin, _state):
	var new_state = evaluate()
	if outputs[0] != new_state:
		outputs[0] = new_state
		emit_signal("state_changed", self, 0, new_state)


func evaluate():
	var result = false
	match gate_type:
		"NOT":
			result = !inputs[0]
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
