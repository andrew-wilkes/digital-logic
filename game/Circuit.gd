extends Node2D

var part_moving = false
var part
var wire_scene = preload("res://parts/misc/Wire.tscn")

func _ready():
	# warning-ignore:return_value_discarded
	$PartsPicker.connect("picked", self, "part_picked")


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseMotion:
		if part_moving:
			part.position = (event.position / g.GRID_SIZE).round() * g.GRID_SIZE
			part.update_wire_positions()
		elif g.wire:
			# Move end of wire
			g.wire.points[1] = event.position
	# Delete wire on release of mouse button
	if event is InputEventMouseButton && g.wire:
		g.wire.delete()
		g.wire = null


func part_picked(node):
	# Should receive a duplicate of the node that was clicked
	set_part_moving(node)
	add_child(part)
	part.connect("picked", self, "set_part_moving")
	part.connect("dropped", self, "part_dropped")
	part.connect("doubleclick", self, "part_delete")
	part.connect("pinclick", self, "pinclick")


func part_dropped():
	part_moving = false
	part.active = true


func set_part_moving(node):
	part = node
	part_moving = true


func part_delete():
	part.delete_wires()
	part.queue_free()


func pinclick(gate, pin):
	if g.wire:
		# Delete uncompleted wire
		g.wire.delete()
		g.wire = null
	if pin.is_output:
		var wire = wire_scene.instance()
		wire.start_pin = pin
		pin.wires.append(wire)
		g.wire = wire
		var pos = gate.position + pin.position
		g.wire.points = [pos, pos]
		$Wires.add_child(wire)
	else:
		if pin.wires.size() > 0:
			pin.wires[0].delete()
