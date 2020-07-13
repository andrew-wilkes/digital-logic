extends Part

enum { A, B, CIN, NIN, ZIN, COMP }
enum { SUM, N, Z }

func _ready():
	allow_testing()
	v_spacing = 72
	z_index = 1 # Display above wires
	connect_signals()
	inputs = [0, 0, false, false, false]
	outputs = [0, false, false]
	var i = 0
	for pin in $Inputs.get_children():
		pin.id = i
		connect_pin(pin)
		i += 1
	i = 0
	for node in $Outputs.get_children():
		node.id = i
		node.is_output = true
		connect_pin(node)
		i += 1
	set_hex()


func update_output(_pin, _state):
	var sum = inputs[A] + inputs[CIN]
	if inputs[COMP]:
		sum -= inputs[B]
	if inputs[ZIN]:
		var z = sum == 0
		if outputs[Z] != z:
			outputs[Z] = z
			emit_signal("state_changed", self, Z, z)
	if inputs[N]:
		var n = sum < 0
		if outputs[N] != n:
			outputs[N] = n
			emit_signal("state_changed", self, N, n)
	if sum > 0xff:
		sum -= 0xff + 1
	elif sum < 0:
		sum = 0xff + sum + 1
	if outputs[SUM] != sum:
		outputs[SUM] = sum
		emit_signal("state_changed", self, SUM, sum)
	set_hex()


func set_hex():
	g.set_hex_text($AV, inputs[A])
	g.set_hex_text($BV, inputs[B])
	g.set_hex_text($SUM, outputs[SUM])
