extends Control

var inputs = []
var outputs = []
var wires = []

class GridWire:
	var start_ob
	var end_obs = []
	var members = []

func _ready():
	#test_get_connected_wires()
	scan_circuit()


# Set up the connectivity between all inputs, gates, and outputs
func scan_circuit():
	# Connect inputs to gates
	inputs = get_inputs()
	outputs = get_outputs()
	get_wires()
	# Get input wires
	for w in wires:
		if w.start_ob is GridInput:
			print(w.start_ob.name)
	pass


func get_inputs():
	return $VBox/Circuit.get_child(0).get_node("In").get_children()


func get_outputs():
	return $VBox/Circuit.get_child(0).get_node("Out").get_children()


func get_wires():
	var lines = []
	var cons = get_cons()
	var stubs = []
	for node in $VBox/Circuit.get_child(0).get_children():
		if node is Line2D:
			lines.append(node)
	# Get wire stubs
	for con in cons:
		for line in lines:
			if (con.position - line.get_points()[0]).length() < 8.0:
				stubs.append(line)
	# Get start wires (wires that are not stubs)
	for line in lines:
		if stubs.has(line):
			continue
		var gw = GridWire.new()
		# Find the part connected to the start of the wire
		gw.start_ob = get_connected_part(line.get_points()[0], get_gates())
		if gw.start_ob == null:
			gw.start_ob = get_connected_part(line.get_points()[0], inputs)
		# Find the parts connected to the ends of the wires
		var cws = get_connected_wires(line, stubs)
		cws.append(line)
		gw.members = cws
		for m in gw.members:
			var part = get_connected_part(m.get_points()[-1], get_gates())
			if part == null:
				part = get_connected_part(m.get_points()[-1], outputs)
			gw.end_obs.append(part)
		wires.append(gw)


func test_get_connected_wires():
	var line1 = Line2D.new() # V
	line1.add_point(Vector2(1, 1))
	line1.add_point(Vector2(1, 6))
	var line2 = Line2D.new() # H
	line2.add_point(Vector2(1, 1))
	line2.add_point(Vector2(4, 1))
	var ws = get_connected_wires(line1, [line2])
	ws = get_connected_wires(line2, [line1])
	ws = get_connected_wires(line2, [line2])
	ws = get_connected_wires(line1, [])
	# Check recursion
	var line3 = Line2D.new() # H
	line3.add_point(Vector2(3, 1))
	line3.add_point(Vector2(3, 6))
	ws = get_connected_wires(line1, [line2, line3])
	print(ws)


func get_connected_wires(line, stubs: Array):
	var cws = []
	for n in range(1, line.get_point_count()):
		var a = line.get_points()[n - 1]
		var b = line.get_points()[n]
		var vert = near(a.x, b.x)
		for stub in stubs:
			if stub == line:
				continue
			var c = stub.get_points()[0]
			if vert:
				if near(a.x, c.x) and on_line(a.y, b.y, c.y):
					cws.append(stub)
					var ws = get_connected_wires(stub, stubs)
					if len(ws) > 0:
						cws = append_array(cws, ws)
			else:
				if near(a.y, c.y) and on_line(a.x, b.x, c.x):
					cws.append(stub)
					var ws = get_connected_wires(stub, stubs)
					if len(ws) > 0:
						cws = append_array(cws, ws)
	return cws


func append_array(a, b):
	for item in b:
		a.append(item)
	return a


func test_on_line():
	print(on_line(1.0, 6.0, 1.0))
	print(on_line(1.0, 6.0, 2.0))
	print(on_line(1.0, 6.0, 4.0))
	print(on_line(1.0, 6.0, 6.0))
	
	print(on_line(1.0, 6.0, 0.5))
	print(on_line(1.0, 6.0, 6.5))
	print(on_line(1.0, 6.0, -0.5))
	print(on_line(1.0, 6.0, -2.0))
	print(on_line(1.0, 6.0, -8.0))


func near(a, b, c = 0.1):
	return abs(a - b) < c


func on_line(a, b, c):
	var l = abs(b - a) * 1.1
	return abs(c - a) < l and abs(b - c) < l

func get_cons():
	return $VBox/Circuit.get_child(0).get_node("Con").get_children()


func get_gates():
	return $VBox/Circuit.get_child(0).get_node("Gates").get_children()


func get_connected_part(point: Vector2, items: Array):
	for gate in items:
		if (gate.rect_position - point).length() < 96.0:
			return gate
