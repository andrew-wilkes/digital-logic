extends Part

var labels = ["I0","I1","I2","I3"]

func _ready():
	allow_testing()
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Outputs.get_children():
		node.id = i
		node.is_output = true
		connect_pin(node)
		outputs.append(false)
		update_output(false, i)
		i += 1
	i = 0
	for node in $Buttons.get_children():
		node.connect("toggled", self, "update_output", [i])
		i += 1


func update_output(value, idx):
	outputs[idx] = value
	$Pins.get_child(idx).modulate = g.get_state_color(value)
	emit_signal("new_event")
	emit_signal("state_changed", self, idx, value)


func reset_outputs():
	for i in outputs.size():
		update_output(false, i)


func set_state(value, idx):
	idx = outputs.size() - idx - 1 # Reverse the order of inputs
	$Buttons.get_child(idx).pressed = value
	update_output(value, idx)
