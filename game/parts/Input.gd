extends Part

func _ready():
	allow_testing()
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	connect_signals()
	connect_pin($Q)
	$Q.is_output = true
	pin_exit($Q) # Hide
