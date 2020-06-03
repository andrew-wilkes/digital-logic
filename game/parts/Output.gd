extends Part

var labels = [] setget ,get_labels

func _ready():
	allow_testing()
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	connect_signals()
	var pin = $Inputs/A
	connect_pin(pin)
	pin.hide_it()
	$Label.hide()
	outputs = [false]
	connect("dropped", self, "show_label")


func get_labels():
	return [$Label.text]


func set_label(txt):
	$Label.text = txt
	labels.append(txt)


func get_state(_idx):
	return state


func update_output(pin, value):
	if pin.state_changed():
		pin.wires[0].delete()
		unstable()
		return
	state = value
	outputs[0] = state
	color = g.get_state_color(state)
	$Symbol.modulate = color


func show_label():
	$Label.show()
