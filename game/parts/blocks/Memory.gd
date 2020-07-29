extends Part

export var memory_size = 256
export var title = ""
export var mem = []
export var src = []

enum { R, W, A, DI }
enum { DO }

func _ready():
	if mem.size() < memory_size:
		mem.resize(memory_size)
		for a in memory_size:
			mem[a] = 0
	set_hex()
	$Title.update_title(title)
	$Title.connect("updated", self, "update_title")


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
	g.mem = mem
	g.src = src
	$c/DataManager.open(title)


func _on_DataManager_popup_hide():
	mem = g.mem
	src = g.src
	set_hex()
