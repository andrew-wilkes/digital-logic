extends Part

func _ready():
	allow_testing()
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	connect_signals()
	connect_pin($Inputs/A)
	pin_exit($Inputs/A) # Hide


func update_output(_node, value):
	change_input_state(value)
