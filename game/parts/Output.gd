extends Part

func _ready():
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	if get_parent().name == "root":
		# Testing scene in isolation
		position = Vector2(100, 100) # Bring into view
		active = true # Enable state changing
	connect_signals()
	connect_pin($Inputs/A)
	pin_exit($Inputs/A) # Hide
