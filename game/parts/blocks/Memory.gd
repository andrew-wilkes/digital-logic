extends Part

var mem = []
export var memory_size = 256

enum { R, W, A, DI }
enum { DO }

func _ready():
	mem.resize(memory_size)
	for a in memory_size:
		mem[a] = 0
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
