extends Control

const CELL_MARGIN = 4

export var goff = Vector2(0, 0)
export var DEBUG = true

var part
var part_to_delete
var wire_scene = preload("res://parts/misc/Wire.tscn")
var picker_scene = preload("res://PartsPicker.tscn")
var astar: AStar2D
var region
var ref
var min_point: Vector2
var max_point: Vector2
var region_size
var panning = false
var pan_pos
var title = ""
var cid = ""
var dots = []

func _ready():
	allow_testing()
	astar = AStar2D.new()
	# warning-ignore:return_value_discarded
	$c/Confirm.connect("confirmed", self, "part_delete")
	# warning-ignore:return_value_discarded
	$c/FileDialog.connect("item_selected", self, "choose_circuit")	
	# warning-ignore:return_value_discarded
	$c/LabelDialog.connect("updated", self, "save_scene")
	region = $Region
	var data = g.load_file(g.PART_FILE_PATH + "data.json")
	if data:
		g.circuits = data
	return get_tree().get_root().connect("size_changed", self, "set_shape_position")


func allow_testing():
	if get_parent().name == "root":
		# Testing scene in isolation
		var p = picker_scene.instance()
		add_child(p)
		# warning-ignore:return_value_discarded
		p.connect("picked", self, "part_picked")


func route_all_wires():
	get_extents()
	region_size = max_point - min_point
	if DEBUG:
		for dot in dots:
			dot.queue_free()
		dots.clear()
		region.visible = true
		region.rect_position = min_point + $Parts.position
		region.rect_size = region_size
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


func show_point(pos):
	var p = $Dot.duplicate()
	p.show()
	p.position = pos
	region.add_child(p)
	dots.append(p)


func add_islands():
	for p in $Parts.get_children():
		var ext = p.get_extents()
		var p1 = get_cell_coor(ext.a)
		var p2 = get_cell_coor(ext.b)
		for y in range(p1.y, p2.y + 1):
			for x in range(p1.x, p2.x + 1):
				var i = x + y * region_size.x
				if astar.has_point(i):
					astar.set_point_disabled(i)
				else:
					breakpoint
				if DEBUG:
					dots[x + y * region_size.x].modulate = Color.bisque


func get_cell_coor(pos):
	return (pos - min_point) / g.GRID_SIZE


func get_extents():
	var init = true
	for p in $Parts.get_children():
		if init:
			min_point = p.position
			max_point = min_point
			init = false
		var ext = p.get_extents() # Uses the Region rectangle of the part and the part's position
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
			part.global_position = (event.position / g.GRID_SIZE).round() * g.GRID_SIZE
			part.update_wire_positions()
		elif g.wire:
			# Move end of wire
			g.wire.points[-1] = event.position - $Wires.global_position
		elif panning:
			var pos = (event.position / g.GRID_SIZE).round() * g.GRID_SIZE
			if !pan_pos:
				pan_pos = pos
			var delta = Vector2(0, 0)
			if pan_pos.x != pos.x:
				delta.x = pos.x - pan_pos.x
			if pan_pos.y != pos.y:
				delta.y = pos.y - pan_pos.y
			if delta.length_squared() > 2:
				pan_pos = pos
				$Wires.position += delta
				$Parts.position += delta
				region.rect_position += delta
	# Delete wire on release of mouse button
	if event is InputEventMouseButton:
		if g.wire &&  !event.pressed:
			g.wire.delete()
			g.wire = null
		if event.pressed && event.button_index == 2:
			panning = true
		if !event.pressed && event.button_index == 2:
			panning = false
			pan_pos = null


func part_picked(_part):
	# Should receive a duplicate of the node that was clicked
	$Parts.add_child(_part)
	part = _part
	connect_part(_part)


func connect_part(_part):
	_part.connect("picked", self, "select_part")
	_part.connect("dropped", self, "part_dropped")
	_part.connect("doubleclick", self, "confirm_part_delete")
	_part.connect("pinclick", self, "pinclick")
	_part.connect("wire_attached", self, "wire_attached")
	_part.connect("state_changed", self, "state_changed")
	_part.connect("new_event", self, "new_event")
	_part.connect("unstable", self, "unstable")


func unstable():
	$c/Warning.popup_centered()
	
func new_event():
	# Reset all part inputs state change monitoring
	for p in $Parts.get_children():
		p.new_event()


func state_changed(node: Part, state):
	# The output state of a part has changed
	for wire in node.get_output_wires([]):
		wire.set_color(state)
		node = wire.end_pin.parent_part
		node.update_output(wire.end_pin, state)


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
		part = null
		call_deferred("route_all_wires")


func select_part(node):
	part = node
	if part.is_ext_input:
		part.state = !part.state


func confirm_part_delete(_part):
	part_to_delete = _part
	$c/Confirm.rect_position = _part.global_position
	$c/Confirm.popup()


func part_delete():
	if part_to_delete:
		part_to_delete.delete_wires()
		part_to_delete.queue_free()
		part_to_delete = null


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
	# Get a rect_size aligning to grid cells so that we have solid edges
	var r = (rect_size / g.GRID_SIZE).ceil() 
	var rect = (r - Vector2(1, 1)) * g.GRID_SIZE
	var c: Color = ProjectSettings.get_setting("rendering/environment/default_clear_color").darkened(0.1)
	rect += goff
	var x = goff.x
	for i in r.x:
		draw_line(Vector2(x, goff.y), Vector2(x, rect.y), c, 1.0)
		x += g.GRID_SIZE
	var y = goff.y
	for i in r.y:
		draw_line(Vector2(goff.x, y), Vector2(rect.x, y), c, 1.0)
		y += g.GRID_SIZE


func set_shape_position():
	var shape = $Area2D/Shape
	var size = rect_size / 2
	shape.position = size
	shape.shape.extents = size


func request_to_choose_circuit():
	$c/FileDialog.popup_centered()


func choose_circuit(_cid):
	cid = _cid
	if cid.empty():
		delete_circuit()
	else:
		load_scene()


func request_to_save_scene():
	if cid.empty():
		$c/LabelDialog.popup_centered()
	else:
		save_scene()


func request_to_load_scene():
	if cid.empty():
		request_to_choose_circuit()
	else:
		load_scene()


func save_scene(_title = ""):
	if _title.empty():
		_title = "Item"
	if cid.empty():
		cid = get_circuit_id()
		title = _title
	var off = $Parts.position
	var circuit = {
		"title": title,
		"parts": [],
		"offset": { "x": off.x, "y": off.y }
	}
	var scene = PackedScene.new()
	var node = $Parts.duplicate()
	for ch in node.get_children():
		print(ch)
		ch.owner = node
	var result = scene.pack(node)
	if result == OK:
		# warning-ignore:return_value_discarded
		ResourceSaver.save(g.PART_FILE_PATH + cid + ".tscn", scene)
	# Assign ids to parts
	var id = 0
	for p in $Parts.get_children():
		p.id = id
		id += 1
	# Save part and wire data
	id = 0
	for p in node.get_children():
		p.owner = node
		var _part = { "id": id, "wires": [], "label": "" }
		for w in $Parts.get_child(id).get_output_wires([]):
			_part.wires.append([w.end_pin.parent_part.id, w.end_pin.id])
		if p.has_method("get_label"):
			_part.label = p.get_label()
		circuit.parts.append(_part)
		id += 1
	g.circuits[cid] = circuit
	g.save_file(g.PART_FILE_PATH + "data.json", g.circuits)


func load_scene():
	delete_circuit()
	var parts = []
	var circuit = g.circuits[cid]
	var packed_scene = ResourceLoader.load(g.PART_FILE_PATH + cid + ".tscn", "", true)
	if packed_scene:
		var scene = packed_scene.instance()
		for p in scene.get_children():
			var np = p.duplicate()
			parts.append(np)
			$Parts.add_child(np)
		scene.queue_free()
		var id = 0
		for p in parts:
			if p.has_method("set_label"):
				p.set_label(circuit.parts[id].label)
			for w in circuit.parts[id].wires:
				var wire = wire_scene.instance()
				wire.start_pin = p.get_node("Q")
				wire.end_pin = parts[w[0]].get_node("Inputs").get_child(w[1])
				wire.clear_points()
				wire.add_point(wire.start_pin.global_position - $Parts.global_position)
				wire.add_point(wire.end_pin.global_position - $Parts.global_position)
				wire.start_pin.wires.append(wire)
				wire.end_pin.wires.append(wire)
				$Wires.add_child(wire)
			connect_part(p)
			id += 1
	route_all_wires()
	var pos = Vector2(circuit.offset.x, circuit.offset.y)
	$Parts.position = pos
	$Wires.position = pos
	title = circuit.title


func delete_circuit():
	for w in $Wires.get_children():
		w.queue_free()
	for p in $Parts.get_children():
		p.queue_free()
	$Parts.position = Vector2(0, 0)
	$Wires.position = $Parts.position


func get_circuit_id():
	var i = 1
	var id = "c"
	while(g.circuits.keys().has(id + String(i))):
		i += 1
	return id + String(i)
