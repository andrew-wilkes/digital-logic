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
		elif g.wire:
			g.wire.points[1] = event.position


func part_picked(node):
	set_part_moving(node)
	part.active = true
	part.connect("picked", self, "set_part_moving")
	part.connect("dropped", self, "part_dropped")
	part.connect("doubleclick", self, "part_delete")
	part.connect("pinclick", self, "pinclick")
	add_child(part)


func part_dropped():
	part_moving = false


func set_part_moving(node):
	part = node
	part_moving = true


func part_delete():
	part.queue_free()


func pinclick(gate, pin):
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
			pin.wires[0].queue_free()
