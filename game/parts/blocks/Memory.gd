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
	var prog = [12,12,3,11,10,6,10,12,9,3,6,7,8]
	for n in prog.size():
		mem[n] = prog[n]


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


func _on_ViewData_button_down():
	$Viewer.open(mem, title)
