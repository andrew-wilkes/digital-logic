extends Part

var labels =  []
var resizing = false

func _ready():
	z_index = 1 # Display above wires
	set_size()
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


func set_size():
	var length = get_length()
	$Symbol.points[1].y = length
	$Symbol.position.y = -length / 2
	$VBox.rect_size.y = length
	$VBox.rect_position.y = -length / 2


func update_output(pin, state):
	# Only update on change of state
	if inputs[pin.id] == state:
		return
	if pin.state_changed():
		pinclick(pin)
		unstable()
		return
	inputs[pin.id] = state
	if !pin.was_connected_to:
		pin.was_connected_to = true


func _on_TopHandle_button_down():
	resizing = true


func _on_TopHandle_button_up():
	resizing = false


func _on_TopHandle_gui_input(event):
	resize(event)


func _on_BottomHandle_button_down():
	resizing = true


func _on_BottomHandle_button_up():
	resizing = false


func _on_BottomHandle_gui_input(event):
	resize(event)


func resize(event):
	if resizing and event is InputEventMouseMotion:
		print(event.position)


func get_length():
	return 40 * ($Inputs.get_child_count() + 1)


func get_min_length():
	# Count connected pins
	var n = 1
	for i in $Inputs.get_child_count():
		if i > 1:
			if $Inputs.get_child(i).wires.size() > 0 or $Outputs.get_child(i).wires.size() > 0:
				n = i
	return n + 1
