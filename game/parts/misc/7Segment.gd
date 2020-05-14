extends Part

onready var s = $Segments

export(Color, RGB) var on_color
export(Color, RGBA) var off_color

var map = [
	0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,0x77,0x7c,0x39,0x5e,0x79,0x71
]

var count = 0
var inputs = []

func _ready():
	if allow_testing():
		set_segment(7, 0)
		$Timer.start()
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Inputs.get_children():
		#node.hide_it()
		inputs.append(false)
		node.id = i
		connect_pin(node)
		i += 1


func set_segment(i: int, b: bool):
		if b:
			s.get_child(i).modulate = on_color
		else:
			s.get_child(i).modulate = off_color


func set_segments(x):
	var n = 1
	for i in 7:
		set_segment(i, n & x)
		n = n << 1


func _on_Timer_timeout():
	set_segments(map[count])
	count += 1
	if count > 0xf:
		count = 0


func update_output(pin: Pin, state):
	# Only update on change of state
	if inputs[pin.id] == state and pin.was_connected_to:
		return
	if pin.state_changed():
		pin.wires[0].delete()
		unstable()
		return
	pin.was_connected_to = true
	inputs[pin.id] = state
	set_segment(pin.id, state)
