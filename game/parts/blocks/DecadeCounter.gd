extends Part

var labels =  []
var count = 0

enum { CLK, RST }
const CO = 10

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
		outputs.append(false)
		i += 1
	outputs[CO] = true


func update_output(_pin, _state):
	if _pin.id == CLK and _state:
		set_output(count, false)
		count += 1
		if count > 9:
			count = 0
			set_output(CO, true)
		set_output(count, true)
		if count == 5:
			set_output(CO, false)
	if _pin.id == RST:
		if _state:
			if count > 0:
				set_output(count, false)
				count = 0
				set_output(count, true)
			if outputs[CO] == false:
				set_output(CO, true)


func set_output(_idx, _v):
	set_output_state($Outputs.get_child(_idx), _v)


func set_output_state(_pin, _state):
	outputs[_pin.id] = _state
	emit_signal("state_changed", self, _pin.id, _state)
