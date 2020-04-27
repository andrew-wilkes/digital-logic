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


func update_output(pin, value):
	if pin.state_changed():
		breakpoint
	change_input_state(value)
