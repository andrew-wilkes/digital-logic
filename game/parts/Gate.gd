extends Node2D

class_name Gate

var input_pin = preload("res://parts/Input.tscn")
var output_pin = preload("res://parts/Output.tscn")
var inputs = []
var output

export(int) var type
export(String) var gate_type

func _ready():
	var i = 0
	for node in $Inputs.get_children():
		show_pin(node, false)
		inputs.append(false)
		if type == 0:
			var pin = input_pin.instance()
			pin.id = i
			i += 1
			pin.connect("state_changed", self, "update_output", [pin])
			node.add_child(pin)
	if type == 0:
		output = output_pin.instance()
		$Q.add_child(output)
		show_pin($Q, false)
	#$Area2D.connect("mouse_entered", self, "mouse_entered")


func pin_enter(node):
	node.get_node("Sprite").show()


func pin_exit(node):
	node.get_node("Sprite").hide()


func mouse_entered():
	pass


func show_pin(node, show = true):
	node.get_node("Sprite").visible = show
	node.connect("mouse_entered", self, "pin_enter", [node])
	node.connect("mouse_exited", self, "pin_exit", [node])


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
