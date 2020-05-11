extends Node2D

class_name Part

signal pinclick(gate, pin)
signal wire_attached(pin, state)
signal state_changed(node, state)
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

var output = false
var state = false setget change_input_state
var dropped = false
var id = 0
var parent
var v_spacing
var color = g.COLOR_UNDEFINED

func allow_testing():
	if get_parent().name == "root":
		# Testing scene in isolation
		position = Vector2(100, 100) # Bring into view


func unstable():
	emit_signal("unstable")


func get_extents():
	return {
		"a": position + $Region.rect_position,
		"b": position + $Region.rect_position + $Region.rect_size
	}


func connect_signals():
	# warning-ignore:return_value_discarded
	$Area2D.connect("mouse_entered", self, "mouse_entered")
	# warning-ignore:return_value_discarded
	$Area2D.connect("mouse_exited", self, "mouse_exited")
	# warning-ignore:return_value_discarded
	$Area2D.connect("input_event", self, "input_event")


func pin_enter(pin: Pin):
	if highlight_pin:
		pin.get_node("Sprite").show()
		# Try to attach end of wire to unconnected input pin
		if g.wire && !pin.is_output && pin.wires.size() < 1:
			var source_part = g.wire.start_pin.get_parent()
			if source_part != self:
				pin.wires.append(g.wire)
				pin.parent_part = self
				g.wire.end_pin = pin
				g.wire.points[-1] = position + pin.position
				g.wire.set_color(source_part.output)
				g.wire = null
				emit_signal("new_event")
				emit_signal("wire_attached", self, pin, source_part.output)


func new_event():
	for pin in $Inputs.get_children():
		pin.reset_state_changed()


func pin_exit(node):
	node.get_node("Sprite").hide()


func mouse_entered():
	if highlight_part:
		$Symbol.modulate = g.COLOR_ACTIVE


func mouse_exited():
	if show_state:
		$Symbol.modulate = color
	elif highlight_part:
		$Symbol.modulate = g.COLOR_UNDEFINED


func connect_pin(node):
	node.connect("mouse_entered", self, "pin_enter", [node])
	node.connect("mouse_exited", self, "pin_exit", [node])
	node.connect("input_event", self, "pin_click", [node])


func pin_click(_viewport, event, _shape_idx, node):
	if event is InputEventMouseButton && event.pressed && wireable:
		# Click on output pin to create a new wire
		# Click on input pin to delete a wire
		pinclick(node)


func pinclick(node):
		emit_signal("pinclick", self, node)


func change_input_state(value):
	state = value
	output = state
	indicate_state()
	emit_signal("new_event")
	emit_signal("state_changed", self, state)


func indicate_state():
	if state:
		color = g.COLOR_HIGH
	else:
		color = g.COLOR_LOW
	$Symbol.modulate = color


func input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.doubleclick:
			emit_signal("doubleclick", self)
		elif event.pressed:
			emit_signal("picked", self)
		else:
			emit_signal("dropped")


func update_wire_positions():
	if has_node("Q"):
		for i in $Q.wires.size():
			$Q.wires[i].points[0] = position + $Q.position
	for pin in $Inputs.get_children():
		if pin.wires.size() > 0:
			pin.wires[0].points[-1] = position + pin.position


func get_wires():
	return get_input_wires(get_output_wires([]))


func get_output_wires(wires):
	if has_node("Q"):
		for i in $Q.wires.size():
			wires.append($Q.wires[i])
	return wires


func get_input_wires(wires):
	for pin in $Inputs.get_children():
		pin.parent_part = self
		if pin.wires.size() > 0:
			wires.append(pin.wires[0])
	return wires


func delete_wires():
	if has_node("Q"):
		for i in $Q.wires.size():
			$Q.wires[0].delete() # The delete operation removes element from array shrinking it.
	for pin in $Inputs.get_children():
		if pin.wires.size() > 0:
			pin.wires[0].delete()
