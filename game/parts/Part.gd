extends Node2D

class_name Part

signal pinclick(gate, pin)
signal wire_attached(pin, state)
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

var outputs = []
var state = false setget change_input_state
var dropped = false
var id = 0
var parent
var v_spacing
var color = g.COLOR_UNDEFINED

func allow_testing():
	var ok = false
	if get_parent().name == "root":
		# Testing scene in isolation
		position = Vector2(100, 100) # Bring into view
		ok = true
	return ok


func unstable():
	emit_signal("unstable")


func get_extents():
	return {
		"a": position + $Region.rect_position,
		"b": position + $Region.rect_position + $Region.rect_size
	}


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
		if g.wire && !pin.is_output && pin.wires.size() < 1:
			var source_part = g.wire.start_pin.parent_part
			if source_part != self:
				var state = source_part.outputs[g.wire.start_pin.id]
				pin.wires.append(g.wire)
				pin.parent_part = self
				g.wire.end_pin = pin
				g.wire.points[-1] = position + pin.position
				g.wire.set_color(state)
				g.wire = null
				emit_signal("new_event")
				emit_signal("wire_attached", self, pin, state)


func pin_exit(pin: Pin):
	if highlight_pin and pin.wires.size() > 0:
		pin.hide_it()


func new_event():
	for pin in $Inputs.get_children():
		pin.reset_state_changed()


func mouse_entered():
	if highlight_part:
		$Symbol.modulate = g.COLOR_ACTIVE


func mouse_exited():
	if show_state:
		$Symbol.modulate = color
	elif highlight_part:
		$Symbol.modulate = g.COLOR_UNDEFINED


func pin_click(_viewport, event, _shape_idx, node):
	if event is InputEventMouseButton && event.pressed && wireable:
		# Click on output pin to create a new wire
		# Click on input pin to delete a wire
		pinclick(node)


func pinclick(node):
	emit_signal("pinclick", self, node)


# Change color of Input part and signal change of state
func change_input_state(value):
	state = value
	outputs[0] = state
	color = g.get_state_color(state)
	$Symbol.modulate = color
	emit_signal("new_event")
	emit_signal("state_changed", self, 0, state)


func input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.doubleclick:
			emit_signal("doubleclick", self)
		elif event.pressed:
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
		for w in pin.wires:
			w.delete() # The delete operation removes element from array shrinking it.
	for pin in $Inputs.get_children():
		if pin.wires.size() > 0:
			pin.wires[0].delete()
