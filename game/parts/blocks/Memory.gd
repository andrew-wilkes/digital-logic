extends Part

var mem = []
export var memory_size = 256
export var title = ""

enum { R, W, A, DI }
enum { DO }

func _ready():
	mem.resize(memory_size)
	for a in memory_size:
		mem[a] = 0
	set_hex()
	$Title.update_title(title)
	$Title.connect("updated", self, "update_title")
	var prog = [12,12,4,11,10,7,10,12,10,3,6,7]
	for n in prog.size():
		mem[n + 1] = prog[n]


func update_title(txt):
	title = txt


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
