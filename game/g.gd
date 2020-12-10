extends Node

const COLOR_HIGH = Color(1, 0.164062, 0) # Orangish
const COLOR_LOW = Color(0.148415, 0.143555, 0.765625)
const COLOR_BUS = Color(0.0, 0.3, 1.0)
const COLOR_ACTIVE = Color.green
const COLOR_UNDEFINED = Color.white
const COLOR_WRONG = Color.red
const COLOR_RIGHT = Color.green
const UNSTABLE_THRESHOLD = 4

var debug_id = 0

func get_debug_id():
	debug_id += 1
	return debug_id


func get_state_color(_state):
	match _state:
		1:
			return COLOR_HIGH
		0:
			return COLOR_LOW
		-1:
			return COLOR_UNDEFINED
		2:
			return COLOR_UNDEFINED


func set_hex_text(label: Label, value: int):
	label.text = "%02X" % value
