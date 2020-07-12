extends Part

var labels =  []
var mem = []
export var memory_size = 256

enum { R, W, A, DI }
enum { DO }

func _ready():
	allow_testing()
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for pin in $Inputs.get_children():
		if i < 2:
			inputs.append(false)
		else:
			inputs.append(0)
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
	mem.resize(memory_size)
	for a in memory_size:
		mem[a] = false
	set_hex()


func update_output(_pin, _state):
	if inputs[R]:
		var v = mem[inputs[A]]
		if outputs[DO] != v:
			outputs[DO] = v
			emit_signal("state_changed", self, DO, v)
	if inputs[W]:
		mem[inputs[A]] = inputs[DI]
	set_hex()


func set_hex():
	g.set_hex_text($Add, inputs[A])
	g.set_hex_text($Data, mem[inputs[A]])
	g.set_hex_text($DI, inputs[DI])
	g.set_hex_text($DO, outputs[DO])
