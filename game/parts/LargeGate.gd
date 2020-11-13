extends Control

var gate = 1
var names = [
	"AND",
	"NAND",
	"OR",
	"NOR",
	"XOR",
	"NOT"
]

enum { CROSS, TICK, Q }

func _ready():
	if get_parent().name == "root":
		set_gate(5)
		$Timer.start()


func set_gate(idx: int):
	gate = idx
	for i in 6:
		get_child(i).visible = i == idx
	get_node("C/Label").text = "%s Gate" % names[idx]


func set_inputs(vals: Array):
	for i in vals.size():
		get_child(gate).get_child(i + 1).modulate = Color.red if vals[i] == 1 else Color.blue

func set_result(r: int):
	for i in 3:
		get_node("C/Result").get_child(i).visible = r == i


func _on_Timer_timeout():
	set_gate(gate)
	if gate == 5:
		set_inputs([randi() % 2])
	else:
		set_inputs([randi() % 2, randi() % 2])
	gate += 1
	gate %= 6
	set_result(randi() % 3)
