extends Part

const REPEAT_INTERVAL = 0.1
const DELAY = 0.5

var delta = 0
var x = 1

func _ready():
	allow_testing()
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Outputs.get_children():
		node.id = i
		node.is_output = true
		connect_pin(node)
		outputs.append(false)
		i += 1
	call_deferred("set_value", -1)


func _on_Up_button_down():
	delta = 1
	set_value(delta)
	$Timer.start(DELAY)


func _on_Down_button_down():
	delta = -1
	set_value(delta)
	$Timer.start(DELAY)


func set_value(d):
	var new_x = clamp(x + d, 0, 15)
	if x == new_x:
		return
	x = new_x
	emit_signal("new_event")
	var n = 1
	for i in 4:
		var b = bool(n & int(x))
		outputs[i] = b
		$Pins.get_child(i).modulate = g.get_state_color(b)
		emit_signal("state_changed", self, i, b)
		n = n << 1
	$VBox/Label.text = "0x%X" % x


func _on_Up_button_up():
	$Timer.stop()


func _on_Down_button_up():
	$Timer.stop()


func _on_Timer_timeout():
	set_value(delta)
	$Timer.start(REPEAT_INTERVAL)
