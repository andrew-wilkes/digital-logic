extends Part

var resizing = false
var resize_factor = 2
var line_length
var start_pos
export var length = 120

func _ready():
	line_length = get_length()
	set_size(line_length)
	$Inputs.position = Vector2(0, 0)
	$Outputs.position = Vector2(0, 0)
	$Area2D.position = Vector2(0, 0)


func set_size(l):
	if l < 100:
		return
	var l2 = l / 2
	$Symbol.points[0].y = -l2
	$Symbol.points[1].y = l2
	$TopHandle.rect_position.y = -l2
	$BottomHandle.rect_position.y = l2 - 8
	length = l


func update_output(_pin, _state):
	if outputs[_pin.id] != _state:
		outputs[_pin.id] = _state
		emit_signal("state_changed", self, 0, _state)


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
	line_length = $Symbol.points[1].y
	start_pos = get_viewport().get_mouse_position().y


func resize(event):
	if resizing and event is InputEventMouseMotion:
		var m_pos = get_viewport().get_mouse_position().y
		var y = 40 * floor((resize_factor * (m_pos - start_pos) + line_length) / 40)
		if y > 110:
			set_size(y)
			var child_count = $Inputs.get_child_count()
			var num_pins = y / 40 - 1
			var pin_diff = num_pins - child_count
			if pin_diff > 0:
				for n in pin_diff:
					var _id = child_count + n
					add_input_pin(_id)
					add_output_pin(_id)
			elif pin_diff < 0:
				var last_i = child_count
				for i in range(child_count - 1, num_pins - 1, -1):
					if i > 1 and $Inputs.get_child(i).wires.size() == 0 and $Outputs.get_child(i).wires.size() == 0:
						$Inputs.get_child(i).queue_free()
						$Outputs.get_child(i).queue_free()
						outputs.remove(i)
						last_i = i
				if last_i < child_count:
					set_size(last_i)


func add_input_pin(_id):
	var pin = $Inputs.get_child(0).duplicate()
	pin.wires.clear()
	pin.position.y = -_id * 20 - 20
	pin.id = _id
	pin.show_it()
	connect_pin(pin)
	inputs.append(false)
	$Inputs.add_child(pin)


func add_output_pin(_id):
	var pin = $Outputs.get_child(0).duplicate()
	pin.wires.clear()
	pin.position.y = _id * 20 + 20
	print(pin.position.y)
	pin.id = _id
	pin.show_it()
	connect_pin(pin)
	outputs.append(false)
	$Outputs.add_child(pin)


func get_length():
	return 40 * ($Inputs.get_child_count() + 1)
