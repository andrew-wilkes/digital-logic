extends Node2D

class_name Part

signal pinclick(gate, pin)
signal wire_attached(node, pin, state)
signal state_changed(node, output_index, state)
signal picked(node)
signal dropped
signal doubleclick
signal new_event
signal unstable

export(bool) var highlight_pin = true
export(bool) var highlight_part = true
export(bool) var moveable = true
export(bool) var wireable = true
export(bool) var show_state = false
export(bool) var is_ext_input = false
export(bool) var is_ext_output = false
export(bool) var is_input_block = false
export(bool) var is_output_block = false

var inputs = []
var outputs = []
var _labels = []
var labels = [] setget set_labels, get_labels
var state = false setget change_input_state
var dropped = false
var id = 0
var parent
var v_spacing = 72
var color = g.COLOR_UNDEFINED

func _ready():
	allow_testing()
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for pin in $Inputs.get_children():
		if pin.is_bus:
			inputs.append(0)
		else:
			inputs.append(false)
		pin.id = i
		connect_pin(pin)
		i += 1
	i = 0
	for pin in $Outputs.get_children():
		if pin.is_bus:
			outputs.append(0)
		else:
			outputs.append(false)
		pin.id = i
		pin.is_output = true
		connect_pin(pin)
		i += 1


func set_labels(value: Array):
	_labels = value


func get_labels():
	return _labels


func update_output(_pin, _state):
	pass


func allow_testing():
	var ok = false
	if get_parent().name == "root":
		# Testing scene in isolation
		position = Vector2(100, 100) # Bring into view
		ok = true
	return ok


func unstable():
	emit_signal("unstable")


func get_postion():
	return $Area2D.position + $Area2D/CollisionShape2D.position


func get_extents():
	return $Area2D/CollisionShape2D.shape.extents


func connect_signals():
	$Area2D.connect("mouse_entered", self, "mouse_entered")
	$Area2D.connect("mouse_exited", self, "mouse_exited")
	$Area2D.connect("input_event", self, "input_event")


func connect_pin(pin: Pin):
	pin.connect("mouse_entered", self, "pin_enter", [pin])
	pin.connect("mouse_exited", self, "pin_exit", [pin])
	pin.connect("input_event", self, "pin_click", [pin])
	pin.parent_part = self


func pin_enter(pin: Pin):
	if highlight_pin:
		pin.show_it()
		# Try to attach end of wire to unconnected input pin
		if g.wire && !pin.is_output && pin.wires.size() < 1 && g.wire.is_bus == pin.is_bus:
			var source_part = g.wire.start_pin.parent_part
			var pin_state = source_part.outputs[g.wire.start_pin.id]
			pin.wires.append(g.wire)
			pin.parent_part = self
			g.wire.end_pin = pin
			g.wire.points[-1] = position + pin.position
			g.wire.set_color(pin_state)
			g.wire = null
			emit_signal("new_event")
			emit_signal("wire_attached", self, pin, pin_state)


func pin_exit(pin: Pin):
	if highlight_pin and pin.wires.size() > 0:
		pin.hide_it()


func new_event():
	for pin in $Inputs.get_children():
		pin.reset_state_changed()


func mouse_entered():
	if highlight_part:
		$Symbol.modulate = g.COLOR_ACTIVE
		hightlight_wires(true)


func mouse_exited():
	if show_state:
		$Symbol.modulate = color
	elif highlight_part:
		$Symbol.modulate = g.COLOR_UNDEFINED
		hightlight_wires(false)


func hightlight_wires(_do):
	for _out in $Outputs.get_children():
		for w in _out.wires:
			w.highlight(_do)
	for _in in $Inputs.get_children():
		for w in _in.wires:
			w.highlight(_do)


func pin_click(_viewport, event, _shape_idx, node):
	if event is InputEventMouseButton && event.pressed && wireable:
		# Click on output pin to create a new wire
		# Click on input pin to delete a wire
		g.clicked_item = "Pin"
		pinclick(node)


func pinclick(node):
	emit_signal("pinclick", self, node)


# Change color of Input part and signal change of state
func change_input_state(value):
	state = bool(value) # May receive a test value for a multi-input part in error
	outputs[0] = state
	color = g.get_state_color(state)
	$Symbol.modulate = color
	emit_signal("new_event")
	emit_signal("state_changed", self, 0, state)


func input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.doubleclick:
			g.clicked_item = "Part"
			emit_signal("doubleclick", self)
		elif event.pressed:
			g.clicked_item = "Part"
			emit_signal("picked", self)
		else:
			emit_signal("dropped")


func highlight_pins():
	for pin in $Outputs.get_children():
		pin.show_it()
	for pin in $Inputs.get_children():
		pin.show_it()


func update_wire_positions():
	for pin in $Outputs.get_children():
		for w in pin.wires:
			w.points[0] = position + pin.position
	for pin in $Inputs.get_children():
		if pin.wires.size() > 0:
			pin.wires[0].points[-1] = position + pin.position


func get_output_wires():
	var w = []
	for pin in $Outputs.get_children():
		w.append(pin.wires)
	return w


func delete_wires():
	for pin in $Outputs.get_children():
		while pin.wires.size() > 0:
			pin.wires.pop_front().delete()
	for pin in $Inputs.get_children():
		if pin.wires.size() > 0:
			pin.wires[0].delete()


func set_input(pin, _state):
	if pin.state_changed(_state):
		pinclick(pin) # Cause wire to be removed
		unstable()
		return
	inputs[pin.id] = _state


func signal_output_states():
	for i in outputs.size():
		emit_signal("state_changed", self, i, outputs[i])
