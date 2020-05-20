extends Part

onready var slider = $VSlider

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
		i += 1


func _on_VSlider_value_changed(x):
	emit_signal("new_event")
	var n = 1
	for i in 4:
		var b = bool(n & int(x))
		outputs[i] = b
		$Pins.get_child(i).modulate = g.get_state_color(b)
		emit_signal("state_changed", self, i, b)
		n = n << 1
