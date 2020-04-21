extends Node2D

class_name Part

signal pinclick(gate, pin)
signal wire_attached
signal state_changed()
signal picked(node)
signal dropped
signal doubleclick

export(int) var mode = 1

var state = false setget set_state
var active = false # Part responds to state change and wire attachments
var id = 0
var v_spacing
var color
var use_state = false

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


func pin_enter(node):
	if active:
		node.get_node("Sprite").show()
		# Try to attach end of wire to unconnected input pin
		if g.wire && !node.is_output && node.wires.size() < 1 && g.wire.start_pin.get_parent() != self:
			node.wires.append(g.wire)
			g.wire.end_pin = node
			g.wire.points[-1] = position + node.position
			g.wire = null
			emit_signal("wire_attached")


func pin_exit(node):
	node.get_node("Sprite").hide()


func mouse_entered():
	if mode > 0:
		$Symbol.modulate = g.COLOR_ACTIVE


func mouse_exited():
	if use_state:
		$Symbol.modulate = color
	elif mode > 0:
		$Symbol.modulate = g.COLOR_UNDEFINED


func connect_pin(node):
	node.connect("mouse_entered", self, "pin_enter", [node])
	node.connect("mouse_exited", self, "pin_exit", [node])
	node.connect("input_event", self, "pin_click", [node])


func pin_click(_viewport, event, _shape_idx, node):
	if event is InputEventMouseButton && event.pressed:
		# Click on output pin to create a new wire
		# Click on input pin to delete a wire
		emit_signal("pinclick", self, node)


func set_state(value):
	state = value
	if state:
		color = g.COLOR_HIGH
	else:
		color = g.COLOR_LOW
	$Symbol.modulate = color
	emit_signal("state_changed")


func input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.doubleclick:
			emit_signal("doubleclick")
		elif event.pressed:
			if active && use_state:
				self.state = !state
			emit_signal("picked", self)
		else:
			active = true
			emit_signal("dropped")


func update_wire_positions():
	if has_node("Q"):
		for i in $Q.wires.size():
			$Q.wires[i].points[0] = position + $Q.position
	for pin in $Inputs.get_children():
		if pin.wires.size() > 0:
			pin.wires[0].points[-1] = position + pin.position


func get_wires():
	var wires = []
	if has_node("Q"):
		for i in $Q.wires.size():
			wires.append($Q.wires[i])
	for pin in $Inputs.get_children():
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
