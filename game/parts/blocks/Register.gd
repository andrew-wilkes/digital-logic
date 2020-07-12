extends Part

var labels = []

enum { CLK, OE, DI, SI }
enum { DO, MO }

# DI is the input bus value
# DO is the output bus value
# MO is the master FF value out
# SI is the slave FF value in

func _ready():
	allow_testing()
	v_spacing = 72
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
		outputs.append(0)
		i += 1
	set_hex()


func update_output(_pin, _state):
	match _pin.id:
		CLK:
			if _state:
				set_output(MO, inputs[DI])
			else:
				set_slave(outputs[MO])
		DI:
			if inputs[CLK]:
				set_output(MO, inputs[DI])
		SI:
			set_slave(_state)
		OE:
			if _state:
				set_output(DO, outputs[SI])
	set_hex()


func set_slave(v):
	inputs[SI] = v
	if inputs[OE]:
		set_output(DO, v)


func set_output(_id, v):
	if outputs[_id] != v:
		outputs[_id] = v
		emit_signal("state_changed", self, _id, v)


func set_hex():
	g.set_hex_text($V1, inputs[DI])
	g.set_hex_text($V2, outputs[MO])
	g.set_hex_text($V3, outputs[DO])
	g.set_hex_text($V4, inputs[SI])
