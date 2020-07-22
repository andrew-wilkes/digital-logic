extends Part

var resizing = false
var resize_factor = 2
var line_length
var start_pos
export var child_count = 2
var val: int = 0

func _ready():
	line_length = get_length(child_count)
	set_size(line_length)
	$Inputs.position = Vector2(0, 0)
	$Outputs.position = Vector2(0, 0)
	$Area2D.position = Vector2(0, 0)
	add_pins()


func add_pins():
	if child_count > 2:
		for _id in range(2, child_count):
			add_input_pin(_id)
			add_output_pin(_id)


func set_size(l):
	if l < 100:
		return
	var l2 = l / 2
	$Symbol.points[0].y = -l2
	$Symbol.points[1].y = l2
	$TopHandle.rect_position.y = -l2
	$BottomHandle.rect_position.y = l2 - 8


func update_output(_pin, _state):
	# All bus I/Os will have the same integer value
	if val != _state:
		val = _state
		for n in child_count:
			outputs[n] = val
		signal_output_states()


func _on_TopHandle_button_down():
	init_resize(-2)


func _on_TopHandle_button_up():
	resizing = false


func _on_TopHandle_gui_input(event):
	resize(event)


func _on_BottomHandle_button_down():
	init_resize(2)


func _on_BottomHandle_button_up():
	resizing = false


func _on_BottomHandle_gui_input(event):
	resize(event)


func init_resize(factor):
	resize_factor = factor
	resizing = true
	line_length = $Symbol.points[1].y * 2
	start_pos = get_viewport().get_mouse_position().y


func resize(event):
	if resizing and event is InputEventMouseMotion:
		var m_pos = get_viewport().get_mouse_position().y
		var y = 20 * floor((resize_factor * (m_pos - start_pos) + line_length) / 20)
		if y > 110:
			var num_pins = int(y / 40 - 1)
			var pin_diff = num_pins - child_count
			if pin_diff > 0:
				for n in pin_diff:
					var _id = child_count
					child_count += 1
					add_input_pin(_id)
					add_output_pin(_id)
			elif pin_diff < 0:
				var new_count = child_count
				for i in range(child_count - 1, num_pins - 1, -1):
					if i > 1 and $Inputs.get_child(i).wires.size() == 0 and $Outputs.get_child(i).wires.size() == 0:
						$Inputs.get_child(i).queue_free()
						$Outputs.get_child(i).queue_free()
						new_count = i
						inputs.remove(i)
						outputs.remove(i)
				child_count = new_count
			set_size(get_length(child_count))


func add_input_pin(_id):
	var pin = $Inputs.get_child(0).duplicate()
	pin.wires.clear()
	pin.position.y = -_id * 20 - 20
	pin.id = _id
	pin.show_it()
	connect_pin(pin)
	$Inputs.add_child(pin)
	inputs.append(0)


func add_output_pin(_id):
	var pin = $Outputs.get_child(0).duplicate()
	pin.wires.clear()
	pin.position.y = _id * 20 + 20
	pin.id = _id
	pin.is_output = true
	pin.show_it()
	connect_pin(pin)
	$Outputs.add_child(pin)
	outputs.append(0)


func get_length(n):
	return 40 * (n + 1)


func signal_output_states():
	for i in child_count:
		emit_signal("state_changed", self, i, val)
