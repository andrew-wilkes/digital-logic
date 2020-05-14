extends Control

var input_part = preload("res://parts/zInput.tscn")
var output_part = preload("res://parts/zOutput.tscn")

func _ready():
	for part in $VBox/Parts.get_children():
		var id = 0
		for pin in part.get_node("Inputs").get_children():
			var i: Part = input_part.instance()
			i.get_node("Label").hide()
			i.highlight_pin = false
			i.moveable = false
			i.wireable = false
			i.show_state = true
			i.is_ext_input = true
			i.z_index = -1
			i.id = id
			i.parent = part
			# warning-ignore:return_value_discarded
			i.connect("picked", self, "clicked")
			i.position = pin.position - i.get_node("Q").position
			part.add_child(i)
			id += 1
		var q: Part = output_part.instance()
		q.get_node("Label").hide()
		q.highlight_pin = false
		q.highlight_part = false
		q.moveable = false
		q.wireable = false
		q.show_state = true
		q.z_index = -1
		q.position = part.get_node("Q").position - q.get_node("Symbol").position
		part.add_child(q)


func clicked(part: Part):
	part.state = !part.state
	part.parent.inputs[part.id] = part.state
	part.parent.set_output(part.state)
	var q = part.parent.get_node("Output")
	q.state = part.parent.output
	q.indicate_state()
