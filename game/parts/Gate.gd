extends Node2D

class_name Gate

var input_positions = []
var output_position: Vector2
var input_pin = preload("res://parts/Input.tscn")
var output_pin = preload("res://parts/Output.tscn")
var inputs = []
var output

export(bool) var add_pins
export(String) var gate_type

func _ready():
	# get connection points
	var n = get_child_count()
	for i in range(1, n - 1):
		var ip = get_child(i)
		input_positions.append(ip.position)
		inputs.append(false)
		if add_pins:
			var pin = input_pin.instance()
			pin.id = i - 1
			pin.connect("state_changed", self, "update_output", [pin])
			ip .add_child(pin)
	var op = get_child(n - 1)
	output_position = op.position
	if add_pins:
		output = output_pin.instance()
		op.add_child(output)


func update_output(pin):
	inputs[pin.id] = pin.state
	var result = false
	match gate_type:
		"NOT":
			result = !pin.state
		"OR", "NOR":
			for b in inputs:
				if b:
					result = b
		"AND", "NAND":
			result = true
			for b in inputs:
				if !b:
					result = false
		"XOR", "XNOR":
			result = inputs[0] != inputs[1]
		_:
			print("Gate type %s unknown!" % gate_type)
	match gate_type:
		"NOR", "NAND", "XNOR":
			result = !result
	output.state = result
