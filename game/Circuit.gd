extends Control

const CELL_MARGIN = 4

signal details_changed(circuit)

var part
var part_to_delete
var wire_scene = preload("res://parts/misc/Wire.tscn")
var picker_scene = preload("res://PartsPicker.tscn")
var in_node = preload("res://parts/zInput.tscn")
var out_node = preload("res://parts/zOutput.tscn")

var ref
var min_point: Vector2
var max_point: Vector2
var panning = false
var pan_pos
var idx = ""
var vx = []
var last_details
var ips = []
var ops = []
var part_pos = Vector2(100, 150)

func _ready():
	allow_testing()
	$c/Confirm.connect("confirmed", self, "part_delete")
	$c/FileDialog.connect("item_selected", self, "choose_circuit")	
	$c/DetailsDialog.connect("updated", self, "save_scene")
	get_tree().get_root().connect("size_changed", self, "set_shape_position")


func set_status(n):
	g.circuits[idx].status = n
	save_scene()


func apply_input(value): # to multi-input part
	var error_code = ips.size() - 1
	if error_code == 0:
		ips[0].state = value
	return error_code


func apply_inputs(vals: Array): # to input pin parts
	var error_code = vals.size() - ips.size()
	if error_code == 0:
		for i in vals.size():
			ips[i].state = vals[i]
	return error_code


func get_output_state(): # from accessory inputs
	if ops.size() > 0:
		return []
	else:
		return ops[0].inputs


func get_output_states(): # from output pin parts
	var s = []
	for op in ops:
		s.append(op.state)
	return s


func get_inputs():
	ips.clear()
	for p in $Parts.get_children():
		if p.is_ext_input or p.is_input_block:
			ips.append({ "part": p, "labels": p.labels })


func get_outputs():
	ops.clear()
	for p in $Parts.get_children():
		if p.is_ext_output or p.is_output_block:
			ops.append({ "part": p, "labels": p.labels })


func add_io_parts(data):
	var i = 0
	var origin = part_pos
	for part_name in data.iparts:
		var node = load("res://parts/accessories/%s.tscn" % part_name).instance()
		node.position = part_pos - node.get_postion()
		var end = i + node.labels.size()
		add_io_block(node, data.inputs.slice(i, end), ips)
		i = end
		part_pos.y += node.get_postion().y + node.get_extents().y + 50
	if i < data.inputs.size():
		add_io(data.inputs.slice(i, data.inputs.size() - 1), in_node, ips)
	origin.x = align_to_grid(rect_size.x) - 150
	part_pos = origin
	for part_name in data.oparts:
		var node = load("res://parts/accessories/%s.tscn" % part_name).instance()
		node.position = part_pos - node.get_postion()
		var end = i + node.labels.size()
		add_io_block(node, data.outputs.slice(i, end), ops)
		i = end
		part_pos.y += node.get_postion().y + node.get_extents().y + 50
	if i < data.outputs.size():
		add_io(data.outputs.slice(i, data.outputs.size() - 1), out_node, ops)


func add_io(labels, resc, list: Array):
	list.clear()
	for txt in labels:
		var node = resc.instance()
		node.set_label(txt)
		node.position = part_pos
		list.append(node)
		part_picked(node)
		part_dropped()
		node.show_label()
		part_pos.y += 50


func add_io_block(node, labels: Array, list: Array):
	list.clear()
	node.labels = labels
	list.append(node)
	part_picked(node)
	part_dropped()


func allow_testing():
	if get_parent().name == "root":
		# Testing scene in isolation
		var p = picker_scene.instance()
		add_child(p)
		p.connect("picked", self, "part_picked")


func route_all_wires():
	vx.clear()
	for w in $Wires.get_children():
		route_wire(w)
	add_dots_to_all_wires()


func route_wire(w):
	var v = w.end_pin.vert
	var a = w.points[0]
	var b = w.points[-1]
	w.clear_points()
	w.add_point(a)
	if a.y != b.y:
		if a.x < b.x:
			var x = b.x
			if !v:
				x = align_to_grid(a.x)
				x = get_next_x(x)
			w.add_point(Vector2(x, a.y))
			w.add_point(Vector2(x, b.y))
		else:
			var x = align_to_grid(a.x)
			x = get_next_x(x)
			w.add_point(Vector2(x, a.y))
			var y = align_to_grid((a.y + b.y) / 2)
			w.add_point(Vector2(x, y))
			x = b.x
			if !v:
				x = align_to_grid(b.x)
				x = get_next_x(x, -2)
			w.add_point(Vector2(x, y))
			w.add_point(Vector2(x, b.y))
	w.add_point(b)


func get_next_x(x, dir = 2):
	var do = true
	while do:
		x += g.GRID_SIZE * dir
		do = vx.has(x)
	vx.append(x)
	return x


func remove_points(w):
	var s = w.points.size()
	if s > 2:
		vx.erase(w.points[2].x)
	if s > 4:
		vx.erase(w.points[3].x)


func align_to_grid(p):
	return round(p / g.GRID_SIZE) * g.GRID_SIZE


func add_dots_to_all_wires():
	# Add dots to 2nd point of all but furthest wire in x direction
	for p in $Parts.get_children():
		for w in p.get_output_wires():
			add_dots_to_wires(w)


func add_dots_to_wires(wires):
		var fidx = get_furthest_index(wires)
		var i = 0
		for w in wires:
			if i == fidx:
				# Remove existing dot
				if w.get_child_count() > 0:
					w.get_child(0).queue_free()
			else:
				var dot
				if w.get_child_count() == 0:
					dot = $Dot.duplicate()
					w.add_child(dot)
					dot.scale *= 0.4
					dot.show()
				else:
					dot = w.get_child(0)
				dot.position = w.points[1]
			i += 1


func get_furthest_index(wires: Array):
	var x = -INF
	var index = 0
	var i = 0
	for w in wires:
		var v = w.points[1].x
		if  v > x:
			x = v
			index = i
		i += 1
	return index


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	# Note that this area defines where the part may be dropped so may define a margin around the viewport edge
	if event is InputEventMouseMotion:
		if part:
			part.position = ((event.position - $Parts.global_position) / g.GRID_SIZE).round() * g.GRID_SIZE
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
	# Delete wire on release of mouse button
	if event is InputEventMouseButton:
		if g.wire &&  !event.pressed:
			if g.wire.start_pin.wires.size() < 2:
				g.wire.start_pin.show_it()
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


func state_changed(node: Part, output_num, state):
	# The output state of a part has changed
	for wire in node.get_output_wires()[output_num]:
		wire.set_color(state)
		node = wire.end_pin.parent_part
		node.update_output(wire.end_pin, state)


func wire_attached(_part, _pin, _status):
	_part.update_output(_pin, _status)
	route_wire(_pin.wires[0])
	add_dots_to_wires(_pin.wires[0].start_pin.wires)


func part_dropped():
	if part:
		part.highlight_pin = true
		part.highlight_part = true
		if !part.dropped:
			part.highlight_pins() # On first drop
			part.dropped = true
			if part.is_ext_input:
				part.change_input_state(false) # Set level to trigger updates of states
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
	if pin.is_output:
		var wire = wire_scene.instance()
		wire.start_pin = pin
		pin.hide_it()
		pin.wires.append(wire)
		g.wire = wire
		var pos = gate.position + pin.position
		g.wire.points = [pos, pos]
		$Wires.add_child(wire)
	else:
		# It's an input pin
		if pin.wires.size() > 0:
			var w = pin.wires[0]
			var start_pin = w.start_pin
			var num_wires = start_pin.wires.size()
			if num_wires < 2:
				start_pin.show_it()
			remove_points(w)
			w.delete()
			add_dots_to_wires(start_pin.wires)


func _draw():
	# Get a rect_size aligning to grid cells so that we have solid edges
	var r = (rect_size / g.GRID_SIZE).ceil() 
	var rect = (r - Vector2(1, 1)) * g.GRID_SIZE
	var c: Color = ProjectSettings.get_setting("rendering/environment/default_clear_color").darkened(0.1)
	var x = 0
	for i in r.x:
		draw_line(Vector2(x, 0), Vector2(x, rect.y), c, 1.0)
		x += g.GRID_SIZE
	var y = 0
	for i in r.y:
		draw_line(Vector2(0, y), Vector2(rect.x, y), c, 1.0)
		y += g.GRID_SIZE


func set_shape_position():
	var shape = $Area2D/Shape
	var size = rect_size / 2
	shape.position = size
	shape.shape.extents = size


func request_to_choose_circuit():
	var editable = false
	if idx.empty():
		last_details = { "title": "Untitled", "desc": "", "id": "-" }
	else:
		last_details = g.circuits[idx]
		editable = last_details.id == "-"
	$c/FileDialog.set_items(editable)


func choose_circuit(_idx):
	match _idx:
		"new":
			idx = ""
			delete_circuit()
			emit_signal("details_changed", { "title": "Untitled", "desc": "", "id": "" } )
		"rename":
			idx = ""
			request_to_save_scene(last_details.title, last_details.desc)
		_:
			idx = _idx
			load_scene()


func request_to_save_scene(title = "", desc = ""):
	var saved = false
	if idx.empty():
		$c/DetailsDialog.set_text(title, desc)
		$c/DetailsDialog.popup_centered()
	else:
		save_scene()
		saved = true
	return saved


func request_to_load_scene():
	var reloaded = false
	if idx.empty():
		request_to_choose_circuit()
	else:
		load_scene()
		reloaded = true
	return reloaded


func save_scene(title = "", description = "", cid = "-", cstatus = 0):
	if idx.empty():
		idx = get_circuit_id()
	else:
		title = g.circuits[idx].title
		description = g.circuits[idx].desc
		cid = g.circuits[idx].id
		cstatus = g.circuits[idx].status
	var off = $Parts.position
	var circuit = {
		"id": cid,
		"title": title,
		"desc": description,
		"parts": [],
		"offset": { "x": off.x, "y": off.y },
		"status": cstatus
	}
	emit_signal("details_changed", circuit)
	var scene = PackedScene.new()
	var node = $Parts.duplicate()
	for ch in node.get_children():
		ch.owner = node
	var result = scene.pack(node)
	if result == OK:
		ResourceSaver.save(g.PART_FILE_PATH + idx + ".tscn", scene)
	# Assign ids to parts
	var id = 0
	for p in $Parts.get_children():
		p.id = id
		id += 1
	# Save part and wire data
	id = 0
	for p in node.get_children():
		p.owner = node
		var _part = { "id": id, "wires": [], "labels": [] }
		for wires in $Parts.get_child(id).get_output_wires():
			var pin_wires = []
			for w in wires:
				pin_wires.append([w.end_pin.parent_part.id, w.end_pin.id])
			_part.wires.append(pin_wires)
		_part.labels = p.labels
		circuit.parts.append(_part)
		id += 1
	g.circuits[idx] = circuit
	g.save_file(g.PART_FILE_PATH + "data.json", g.circuits)


func load_scene():
	delete_circuit()
	$Wires.hide()
	var parts = []
	var circuit = g.circuits[idx]
	var pos = Vector2(circuit.offset.x, circuit.offset.y)
	$Parts.position = pos
	$Wires.position = pos
	var packed_scene = ResourceLoader.load(g.PART_FILE_PATH + idx + ".tscn", "", true)
	if packed_scene:
		var scene = packed_scene.instance()
		for p in scene.get_children():
			var np = p.duplicate()
			np.dropped = true # Suppress highlighting of pins on move
			parts.append(np)
			$Parts.add_child(np)
			np.highlight_pins()
		scene.queue_free()
		var id = 0
		for p in parts:
			if p.has_method("show_label"):
				p.show_label()
			p.labels = circuit.parts[id].labels
			for pin_wires in circuit.parts[id].wires:
				for w in pin_wires:
					# w is [end_pin.parent_part.id, end input pin.id]
					var wire = wire_scene.instance()
					wire.start_pin = p.get_node("Outputs").get_child(0)
					wire.start_pin.parent_part = p
					wire.start_pin.hide_it()
					wire.end_pin = parts[w[0]].get_node("Inputs").get_child(w[1])
					wire.end_pin.parent_part = parts[w[0]]
					wire.end_pin.hide_it()
					wire.clear_points()
					wire.add_point(wire.start_pin.global_position - $Parts.global_position)
					wire.add_point(wire.end_pin.global_position - $Parts.global_position)
					wire.start_pin.wires.append(wire)
					wire.end_pin.wires.append(wire)
					$Wires.add_child(wire)
			connect_part(p)
			id += 1
	init_input_states()
	# Need a delay to allow for previous circuit to be fully deleted
	yield(get_tree(), "idle_frame")
	route_all_wires()
	$Wires.show()
	emit_signal("details_changed", circuit)


func init_input_states():
	for p in $Parts.get_children():
		if p.is_ext_input:
			p.state = false
		if p.is_input_block:
			p.reset_outputs()


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


func _on_FileDialog_item_deleted():
	idx = ""
