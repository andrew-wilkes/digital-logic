tool
extends Control

class_name GridGate

signal changed

enum { AND, NAND, OR, NOR, XOR, NOT }

var gates = []
export var id = 4 setget set_gate

var inputs = {} # Object references that connect to the inputs
var output # Ref to Grid Wire that the output connects to

func _ready():
	# Connect signals
	for gate in get_children():
		gates.append(gate)
		gate.connect("button_down", self, "tapped")
		#gate.rect_position = Vector2(128, 128)
	set_gate(id)
	$XOR/Label.text = String(get_instance_id())


func tapped():
	if id < 5: # Only change 2-input gates
		set_gate((id + 1) % 5)
		emit_signal("changed")


func set_gate(_id):
	var idx = 0
	for gate in get_children():
		gate.visible = _id == idx
		idx += 1
	id = _id
	property_list_changed_notify()


func set_to_obscured():
	if id == NOT:
		return
	id = XOR # XOR
	var idx = 0
	for gate in get_children():
		gate.visible = id == idx
		idx += 1


func eval_inputs():
	var v = []
	for w in inputs.keys():
		v.append(int(w.state))
	return bool(get_output(v))


func get_output(v):
	match id:
		AND:
			return v[0] & v[1]
		NAND:
			return !(v[0] & v[1])
		OR:
			return v[0] | v[1]
		NOR:
			return !(v[0] | v[1])
		XOR:
			return v[0] ^ v[1]
		NOT:
			return !v[0]
