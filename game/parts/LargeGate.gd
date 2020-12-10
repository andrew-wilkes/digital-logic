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

func _ready():
	if get_parent().name == "root":
		set_gate(5)
		$Timer.start()
	else:
		reset()


func reset():
	set_gate(4) # XOR gate
	for i in 3:
		$x/g.get_child(gate).get_child(i).modulate = g.get_state_color(2)


func set_gate(idx: int):
	gate = idx
	for i in 6:
		$x/g.get_child(i).visible = i == idx
	get_node("x/C/Label").text = "%s Gate" % names[idx]
	set_result(2)


func set_inputs():
	var vals: Array
	if gate == 5:
		vals = [randi() % 2]
	else:
		vals = [randi() % 2, randi() % 2]
	for i in vals.size():
		$x/g.get_child(gate).get_child(i + 1).modulate = g.get_state_color(vals[i])
	return vals


func set_output(v):
	$x/g.get_child(gate).get_child(0).modulate = g.get_state_color(v)


func set_result(r: int):
	for i in 3:
		get_node("x/C/Result").get_child(i).visible = r == i


func _on_Timer_timeout():
	set_gate(gate)
	gate += 1
	gate %= 6
	set_result(randi() % 3)
