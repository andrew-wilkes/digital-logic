extends Part

var labels =  []
var resizing = false
var resize_factor = 2
var line_length
var start_pos
export var length = 120

func _ready():
	z_index = 1 # Display above wires
	line_length = get_length()
	set_size(line_length)
	$Inputs.position = Vector2(0, 0)
	$Outputs.position = Vector2(0, 0)
	$Area2D.position = Vector2(0, 0)
	allow_testing()
	connect_signals()
	var i = 0
	for pin in $Inputs.get_children():
		inputs.append(false)
		pin.id = i
		connect_pin(pin)
		i += 1
	i = 0
	for node in $Outputs.get_children():
		node.id = i
		node.is_output = true
		connect_pin(node)
		outputs.append(false)
		i += 1


func set_size(l):
	var l2 = length / 2
	$Symbol.points[0].y = -l2
	$Symbol.points[1].y = l2
	$TopHandle.rect_position.y = -l2
	$BottomHandle.rect_position.y = l2 - 8
	length = l


func update_output(_pin, _state, force = false):
	if _pin != 0 and (outputs[_pin.id] != _state or force):
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
		var y = 40 * floor((resize_factor * (get_viewport().get_mouse_position().y - start_pos) + line_length) / 40)
		if y > 110:
			set_size(y)
			var child_count = $Inputs.get_child_count()
			var num_pins = y / 40 - 1
			var pin_diff = num_pins - child_count
			if pin_diff > 0:
				for n in pin_diff:
					var id = child_count + n
					add_input_pin(id)
					add_output_pin(id)
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
	pin.position.y = _id * 20 + 20
	pin.id = _id
	pin.show_it()
	connect_pin(pin)
	inputs.append(false)
	$Inputs.add_child(pin)


func add_output_pin(_id):
	var pin = $Outputs.get_child(0).duplicate()
	pin.wires.clear()
	pin.position.y = -_id * 20 - 20
	pin.id = _id
	pin.show_it()
	connect_pin(pin)
	outputs.append(false)
	$Outputs.add_child(pin)


func get_length():
	return 40 * ($Inputs.get_child_count() + 1)
