extends Part

onready var s = $Segments

export(Color, RGB) var on_color
export(Color, RGBA) var off_color
export(bool) var decode = false

var map = [
	0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,0x77,0x7c,0x39,0x5e,0x79,0x71
]

var count = 0
var inputs = []

func _ready():
	if allow_testing():
		set_segment(7, 0)
		$Timer.start()
	else:
		set_segments(0)
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Inputs.get_children():
		#node.hide_it()
		inputs.append(false)
		node.id = i
		connect_pin(node)
		i += 1
	if decode:
		$Pins1.hide()
		$Pins2.show()
		# Move inputs
		for i in 5:
			$Inputs.get_child(i).position = $Pins2.get_child(i).position
		for i in range(5, 8):
			$Inputs.get_child(i).hide()


func set_segment(i: int, b: bool):
		if b:
			s.get_child(i).modulate = on_color
		else:
			s.get_child(i).modulate = off_color
		if !decode:
			$Pins1.get_child(i).modulate = g.get_state_color(b)


func set_segments(x):
	var n = 1
	for i in 8:
		set_segment(i, n & x)
		n = n << 1


func _on_Timer_timeout():
	set_segments(get_map(count))
	count += 1
	if count > 0x1f:
		count = 0


func get_map(n):
	return map[n & 0xf] + (n & 0x10) * 0x8


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
	if decode:
		g.indicate_state($Pins2.get_child(pin.id), state)
		set_segments(decode_inputs())
	else:
		set_segment(pin.id, state)


func decode_inputs():
	var x = 0
	for i in 5:
		x = x << 1
		if inputs.pop_back():
			x += 1
	return x
