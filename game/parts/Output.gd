extends Part

func _ready():
	allow_testing()
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	connect_signals()
	var pin = $Inputs/A
	connect_pin(pin)
	pin_exit(pin) # Hide


func get_label():
	return $Label.text


func set_label(txt):
	$Label.text = txt


func update_output(pin, value):
	if pin.state_changed():
		pin.wires[0].delete()
		unstable()
		return
	state = value
	output = state
	indicate_state()


func _on_Label_button_down():
	$c/LabelDialog.popup_centered()


func _on_LabelDialog_updated(txt):
	if txt.empty():
		txt = "?"
	$Label.text = txt
