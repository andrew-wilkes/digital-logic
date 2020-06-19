extends Part

var labels = [] setget set_labels, get_label

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


func get_label():
	return [$Label.text]


func set_labels(arr):
	if arr.empty():
		$Label.text = "?"
	else:
		set_label(arr[0])


func set_label(txt):
	if txt.empty():
		txt = "?"
	$Label.text = txt
	labels = [txt]


func get_state(_idx):
	return state


func set_input(pin, value):
	if pin.state_changed(value):
		pinclick(pin) # Cause wire to be removed
		unstable()
		return
	state = value


func update_output(_force = false):
	outputs[0] = state
	color = g.get_state_color(state)
	$Symbol.modulate = color


func show_label():
	$Label.show()
