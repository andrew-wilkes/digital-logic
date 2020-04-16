extends Node2D

class_name Gate

signal picked(node)

var input_pin = preload("res://parts/Input.tscn")
var output_pin = preload("res://parts/Output.tscn")
var inputs = []
var output
var active = false

export(int) var type = 1
export(String) var gate_type

func _ready():
	# warning-ignore:return_value_discarded
	$Area2D.connect("mouse_entered", self, "mouse_entered")
	# warning-ignore:return_value_discarded
	$Area2D.connect("mouse_exited", self, "mouse_exited")
	var i = 0
	for node in $Inputs.get_children():
		pin_exit(node)
		inputs.append(false)
		if type == 0:
			var pin = input_pin.instance()
			pin.id = i
			i += 1
			pin.connect("state_changed", self, "update_output", [pin])
			node.add_child(pin)
		else:
			connect_pin(node)
	pin_exit($Q) # Hide
	if type == 0:
		output = output_pin.instance()
		$Q.add_child(output)


func pin_enter(node):
	if active:
		node.get_node("Sprite").show()


func pin_exit(node):
	node.get_node("Sprite").hide()


func mouse_entered():
	$Symbol.modulate = Color.green


func mouse_exited():
	$Symbol.modulate = Color.white


func connect_pin(node):
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


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		emit_signal("picked", self)
