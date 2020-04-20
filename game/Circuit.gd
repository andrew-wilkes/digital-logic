extends Node2D

const DEBUG = true
const CELL_MARGIN = 4

var part_moving = false
var part
var wire_scene = preload("res://parts/misc/Wire.tscn")
var astar: AStar2D
var region
var ref
var min_point = Vector2(-1, 0)
var max_point: Vector2
var region_size

func _ready():
	astar = AStar2D.new()
	# warning-ignore:return_value_discarded
	$PartsPicker.connect("picked", self, "part_picked")


func route_wires():
	get_extents()
	region_size = max_point - min_point
	if DEBUG:
		show_region()
	region_size = region_size / g.GRID_SIZE + Vector2(1, 1)
	astar.clear()
	var num_points = region_size.x * region_size.y
	if astar.get_point_capacity() < num_points:
		astar.reserve_space(num_points)
	var i = 0
	for x in region_size.x:
		for y in region_size.y:
			var pos = Vector2(x, y) * g.GRID_SIZE
			astar.add_point(i, pos + min_point)
			i += 1
			if DEBUG:
				show_point(pos)


func show_region():
	if region:
		region.queue_free()
		region = null
	region = ReferenceRect.new()
	add_child(region)
	region.editor_only = false
	region.mouse_filter = Control.MOUSE_FILTER_IGNORE
	region.rect_position = min_point
	region.rect_size = region_size


func show_point(pos):
	var p = $Dot.duplicate()
	p.show()
	p.position = pos
	region.add_child(p)


func get_extents():
	min_point.x = -1
	for p in $Parts.get_children():
		if min_point.x < 0:
			min_point = p.position
			max_point = min_point
		var ext = p.get_extents()
		min_point.x =  min(ext.a.x, min_point.x)
		min_point.y =  min(ext.a.y, min_point.y)
		max_point.x = max(ext.b.x, max_point.x)
		max_point.y = max(ext.b.y, max_point.y)
	# Add margins
	var margin = g.GRID_SIZE * CELL_MARGIN
	min_point.x -= margin
	min_point.y -= margin
	max_point.x += margin
	max_point.y += margin


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
	$Parts.add_child(part)
	part.connect("picked", self, "set_part_moving")
	part.connect("dropped", self, "part_dropped")
	part.connect("doubleclick", self, "part_delete")
	part.connect("pinclick", self, "pinclick")


func part_dropped():
	part_moving = false
	part.active = true
	route_wires()


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

func _draw():
	var r = get_viewport_rect().size
	var c: Color = ProjectSettings.get_setting("rendering/environment/default_clear_color").darkened(0.1)
	var x = 0
	for i in r.x / g.GRID_SIZE:
		draw_line(Vector2(x, 0), Vector2(x, r.y), c, 1.0)
		x += g.GRID_SIZE
	var y = 0
	for i in r.y / g.GRID_SIZE:
		draw_line(Vector2(0, y), Vector2(r.x, y), c, 1.0)
		y += g.GRID_SIZE
