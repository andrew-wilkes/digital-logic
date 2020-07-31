extends Part

var accept_dropped = true

func _ready():
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	$Inputs/A.hide_it()
	$Label.hide()
	outputs = [false]
	if accept_dropped:
		connect("dropped", self, "show_label")


func get_labels():
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


func update_output(_pin, _state):
	outputs[0] = state
	color = g.get_state_color(state)
	$Symbol.modulate = color


func show_label():
	$Label.show()
