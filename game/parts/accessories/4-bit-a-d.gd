extends Part

func _ready():
	labels =  ["I0","I1","I2","I3"]
	call_deferred("_on_VSlider_value_changed", 0)


func _on_VSlider_value_changed(x):
	emit_signal("new_event")
	var n = 1
	for i in 4:
		var b = bool(n & int(x))
		outputs[i] = b
		$Pins.get_child(i).modulate = g.get_state_color(b)
		emit_signal("state_changed", self, i, b)
		n = n << 1


func set_state(value, idx):
	outputs[idx] = value
	$VSlider.value = g.decode_inputs(outputs)


func update_output(value, idx):
	set_state(value, idx)


func reset_outputs():
	for idx in outputs.size():
		outputs[idx] = false
	$VSlider.value = 0
