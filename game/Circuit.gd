extends Control

const CELL_MARGIN = 4

export var DEBUG = true

var part
var part_to_delete
var wire_scene = preload("res://parts/misc/Wire.tscn")
var picker_scene = preload("res://PartsPicker.tscn")
var ref
var min_point: Vector2
var max_point: Vector2
var panning = false
var pan_pos
var title = ""
var cid = ""
var goff

func _ready():
	goff = $Area2D.global_position - ($Area2D.global_position / g.GRID_SIZE).floor() * g.GRID_SIZE
	goff /= 2
	allow_testing()
	# warning-ignore:return_value_discarded
	$c/Confirm.connect("confirmed", self, "part_delete")
	# warning-ignore:return_value_discarded
	$c/FileDialog.connect("item_selected", self, "choose_circuit")	
	# warning-ignore:return_value_discarded
	$c/LabelDialog.connect("updated", self, "save_scene")
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
	for w in $Wires.get_children():
		route_wire(w)


func route_wire(w):
		var a = w.points[0]
		var b = w.points[-1]
		w.clear_points()
		w.add_point(a)
		if a.y != b.y:
			if a.x < b.x:
				var x = align_to_grid((a.x + b.x) / 2)
				w.add_point(Vector2(x, a.y))
				w.add_point(Vector2(x, b.y))
			else:
				var dx = g.GRID_SIZE if a.y > b.y else 2 * g.GRID_SIZE
				var x = align_to_grid(a.x + dx)
				w.add_point(Vector2(x, a.y))
				var y = align_to_grid((a.y + b.y) / 2)
				w.add_point(Vector2(x, y))
				x = align_to_grid(b.x - dx)
				w.add_point(Vector2(x, y))
				w.add_point(Vector2(x, b.y))
		w.add_point(b)


func align_to_grid(p):
	return round(p / g.GRID_SIZE) * g.GRID_SIZE


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	# Note that this area defines where the part may be dropped so may define a margin around the viewport edge
	if event is InputEventMouseMotion:
		if part:
			part.global_position = (event.position / g.GRID_SIZE).round() * g.GRID_SIZE - goff
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


func state_changed(node: Part, state):
	# The output state of a part has changed
	for wire in node.get_output_wires([]):
		wire.set_color(state)
		node = wire.end_pin.parent_part
		node.update_output(wire.end_pin, state)


func wire_attached(_part, _pin, _status):
	_part.update_output(_pin, _status)
	route_wire(_pin.wires[0])


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
			if w.start_pin.wires.size() < 2:
				w.start_pin.show_it()
			w.delete()


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
	$c/FileDialog.popup_centered()


func choose_circuit(_cid):
	cid = _cid
	if cid.empty():
		delete_circuit()
	else:
		load_scene()


func request_to_save_scene():
	if cid.empty():
		$c/LabelDialog.window_title = "Enter circuit name"
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
	var pos = Vector2(circuit.offset.x, circuit.offset.y)
	$Parts.position = pos
	$Wires.position = pos
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
				# w is [end_pin.parent_part.id, end input pin.id]
				var wire = wire_scene.instance()
				wire.start_pin = p.get_node("Q")
				wire.start_pin.parent_part = p
				wire.end_pin = parts[w[0]].get_node("Inputs").get_child(w[1])
				wire.end_pin.parent_part = parts[w[0]]
				wire.clear_points()
				wire.add_point(wire.start_pin.global_position - $Parts.global_position)
				wire.add_point(wire.end_pin.global_position - $Parts.global_position)
				wire.start_pin.wires.append(wire)
				wire.end_pin.wires.append(wire)
				$Wires.add_child(wire)
			connect_part(p)
			id += 1
	route_all_wires()
	init_input_states()
	title = circuit.title


func init_input_states():
	for p in $Parts.get_children():
		if p.is_ext_input:
			p.state = false


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
	cid = ""
