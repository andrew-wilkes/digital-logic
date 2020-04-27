extends Node2D

const DEBUG = false
const CELL_MARGIN = 4

var part
var wire_scene = preload("res://parts/misc/Wire.tscn")
var astar: AStar2D
var region
var ref
var min_point = Vector2(-1, 0)
var max_point: Vector2
var region_size
var panel_corner

func _ready():
	astar = AStar2D.new()
	# warning-ignore:return_value_discarded
	$PartsPicker.connect("picked", self, "part_picked")
	var p = $PartsPicker/Panel
	panel_corner = p.rect_position + p.rect_size


func is_over_panel(node: Part):
	return node.position.x < panel_corner.x and node.position.y < panel_corner.y


func state_changed(node: Part, state):
	# The output state of a part has changed
	for wire in node.get_output_wires([]):
		wire.set_color(state)
		node = wire.end_pin.parent_part
		node.update_output(wire.end_pin, state)


func route_all_wires():
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
	for y in region_size.y:
		for x in region_size.x:
			var pos = Vector2(x, y) * g.GRID_SIZE
			astar.add_point(i, pos + min_point)
			i += 1
			if DEBUG:
				show_point(pos)
	add_islands()
	connect_points()
	for p in $Parts.get_children():
		route_wires(p)


func route_wires(_part):
	for wire in _part.get_wires():
		var first_point = wire.points[0]
		var last_point = wire.points[-1]
		var p = get_cell_coor(first_point)
		var dx = 2
		var p1 = get_active_grid_id(p, dx) # Cell to the right
		while p1 < 0:
			dx += 1
			p1 = get_active_grid_id(p, dx)
		p = get_cell_coor(last_point)
		dx = -2
		var p2 = get_active_grid_id(p, dx) # Cell to the left
		while p2 < 0:
			dx -= 1
			p2 = get_active_grid_id(p, dx)
		var inter_points = astar.get_point_path(p1, p2)
		# Increase the weights of wire points
		var ids = astar.get_id_path(p1, p2)
		for id in ids:
			astar.set_point_weight_scale(id, 2)
		wire.clear_points()
		var points : PoolVector2Array = [first_point]
		points.append_array(inter_points)
		points.append(last_point)
		wire.set_points(points)


func get_active_grid_id(p, dx):
	var id = get_grid_id(p.x + dx, p.y)
	if astar.is_point_disabled(id):
		return -1
	else:
		return id


func connect_points():
	for y in region_size.y - 1:
		for x in region_size.x - 1:
			var p1 = get_grid_id(x, y)
			if !astar.is_point_disabled(p1):
				try_connect(p1, p1 + 1)
				try_connect(p1, p1 + region_size.x)
				try_connect(p1, p1 + region_size.x + 1)
				try_connect(p1, p1 + region_size.x - 1)


func try_connect(p1, p2):
	if !astar.is_point_disabled(p2):
		astar.connect_points(p1, p2)


func get_grid_id(x, y):
	return int(x + region_size.x * y)


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


func add_islands():
	for p in $Parts.get_children():
		var ext = p.get_extents()
		var p1 = get_cell_coor(ext.a)
		var p2 = get_cell_coor(ext.b)
		for y in range(p1.y, p2.y + 1):
			for x in range(p1.x, p2.x + 1):
				var i = x + y * region_size.x
				astar.set_point_disabled(i)
				if DEBUG:
					region.get_child(x + y * region_size.x).modulate = Color.bisque


func get_cell_coor(pos):
	return (pos - min_point) / g.GRID_SIZE


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
	# Note that this area defines where the part may be dropped so may define a margin around the viewport edge
	if event is InputEventMouseMotion:
		if part:
			part.position = (event.position / g.GRID_SIZE).round() * g.GRID_SIZE
			part.update_wire_positions()
		elif g.wire:
			# Move end of wire
			g.wire.points[-1] = event.position
	# Delete wire on release of mouse button
	if event is InputEventMouseButton && g.wire:
		g.wire.delete()
		g.wire = null


func part_picked(node):
	# Should receive a duplicate of the node that was clicked
	part = node
	$Parts.add_child(part)
	part.connect("picked", self, "select_part")
	part.connect("dropped", self, "part_dropped")
	part.connect("doubleclick", self, "part_delete")
	part.connect("pinclick", self, "pinclick")
	part.connect("wire_attached", self, "wire_attached")
	part.connect("state_changed", self, "state_changed")


func wire_attached(_part, _pin, _status):
	_part.update_output(_pin, _status)
	route_wires(_part)


func part_dropped():
	if part:
		part.highlight_pin = true
		part.highlight_part = true
		if part.is_ext_input and !part.dropped:
			part.change_input_state(false) # Set level to trigger updates of states
		part.dropped = true
		if is_over_panel(part):
			part_delete(part)
		part = null
		route_all_wires()


func select_part(node):
	part = node
	if part.is_ext_input:
		part.state = !part.state


func part_delete(_part):
	_part.delete_wires()
	_part.queue_free()
	part = null


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
