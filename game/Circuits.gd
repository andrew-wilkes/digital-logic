extends Control

var inputs = []
var outputs = []
var gates = []
var wires = []
var values = []
var level = 0
var num_levels = 0
var correct_count = 0

class GridWire:
	var start_ob
	var end_obs = []
	var members = []
	var state = false
	var changed = false # Flag to detect unstable state

func _ready():
	#test_get_connected_wires()
	values = $VBox/Circuit.get_child(0).values
	scan_circuit()


enum { PREV, NEXT, STEP } # Enents

func sm(event):
	match event:
		PREV:
			pass
		NEXT:
			drive_circuit(level)
			change_level()
		STEP:
			pass


func gate_changed():
	correct_count = 0


func change_level():
	level += 1
	level %= num_levels


# Set up the connectivity between all inputs, gates, and outputs
func scan_circuit():
	# Connect inputs to gates
	inputs = get_inputs()
	outputs = get_outputs()
	gates = get_gates()
	wires = get_wire_nets()
	num_levels = int(pow(2, inputs.size()))


func drive_circuit(_level: int):
	# Get input wires
	var iws = []
	var bit = 1
	for w in wires:
		w.changed = false # Reset the wires
		if w.start_ob is GridInput:
			iws.append(w)
			var state = (_level & bit) > 0
			set_wire_state(w, state)
			bit = bit << 1
		else:
			set_wire_state(w, false)
	set_outputs(iws)
	# Check correctness
	if check_outputs(_level):
		correct_count += 1
		if correct_count >= num_levels:
			breakpoint
	else:
		correct_count = 0


func set_wire_state(w, v):
	w.state = v
	# Set input color
	if w.start_ob.has_method("set_level"):
		w.start_ob.set_level(v)
	# Set color of wires
	for m in w.members:
		m.modulate = g.get_state_color(v)
	# Assign wire to gate inputs unless already assigned
	for g in w.end_obs:
		if g.has_method("set_level"):
			g.set_level(v)
		var not_set = true
		for ip in g.inputs:
			if ip == w:
				not_set = false
				continue
		if not_set:
			g.inputs.append(w)


func set_outputs(gws):
	if len(gws) < 1:
		return
	var next_wires = []
	for w in gws:
		for ob in w.end_obs:
			if ob is GridGate:
				# Set the state of the gate's output wire
				var v = ob.eval_inputs()
				if ob.output.state != v:
					set_wire_state(ob.output, v)
					if ob.output.changed:
						breakpoint # Unstable condition
					ob.output.changed = true
					next_wires.append(ob.output)
			else:
				# Set output pin level
				ob.set_level(w.state)
	set_outputs(next_wires)


func check_outputs(n):
	var passed = true
	for i in outputs.size():
		var v = outputs[i].state == bool(values[n][i])
		if !v:
			passed = false
		outputs[i].set_result(v)
	return passed


func get_inputs():
	return $VBox/Circuit.get_child(0).get_node("In").get_children()


func get_outputs():
	return $VBox/Circuit.get_child(0).get_node("Out").get_children()


func get_wire_nets():
	var gws = []
	var lines = []
	var cons = get_cons()
	var stubs = []
	var stub_con = {}
	for node in $VBox/Circuit.get_child(0).get_children():
		if node is Line2D:
			lines.append(node)
	# Get wire stubs
	for con in cons:
		for line in lines:
			if (con.position - line.get_points()[0]).length() < 8.0:
				stubs.append(line)
				stub_con[line] = con # Map stub to con
	# Get start wires (wires that are not stubs)
	for line in lines:
		if stubs.has(line):
			continue
		var gw = GridWire.new()
		# Find the part connected to the start of the wire
		gw.start_ob = get_connected_part(line.get_points()[0], gates)
		if gw.start_ob == null:
			gw.start_ob = get_connected_part(line.get_points()[0], inputs)
		else:
			gw.start_ob.output = gw # Ref this wire with the gate's output
		# Find the parts connected to the ends of the wires
		var cws = get_connected_wires(line, stubs)
		var members = cws.duplicate()
		members.append(line)
		for member in members:
			var part = get_connected_part(member.get_points()[-1], gates)
			if part == null:
				part = get_connected_part(member.get_points()[-1], outputs)
			gw.end_obs.append(part)
			# Append cons
		for w in cws:
			members.append(stub_con[w])
		gw.members = members
		gws.append(gw)
	return gws


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
					append_stubs(cws, stub, stubs)
			else:
				if near(a.y, c.y) and on_line(a.x, b.x, c.x):
					append_stubs(cws, stub, stubs)
	return cws


func append_stubs(cws, stub, stubs):
	if !cws.has(stub): # Stop corner connected stub being added twice
		cws.append(stub)
		var ws = get_connected_wires(stub, stubs)
		if len(ws) > 0:
			cws = append_array(cws, ws)


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


# Like is_equal_approx
func near(a, b, c = 0.1):
	return abs(a - b) < c


# Like Inverse Lerp
func on_line(a, b, c):
	var l = abs(b - a) * 1.1
	return abs(c - a) < l and abs(b - c) < l


func get_cons():
	return $VBox/Circuit.get_child(0).get_node("Con").get_children()


func get_gates():
	gates = $VBox/Circuit.get_child(0).get_node("Gates").get_children()
	for gate in gates:
		gate.connect("changed", self, "gate_changed")
	return gates


func get_connected_part(point: Vector2, items: Array):
	for gate in items:
		if (gate.rect_position - point).length() < 96.0:
			return gate


func _on_Step_button_down():
	sm(NEXT)


func _on_PreviousButton_button_down():
	pass # Replace with function body.


func _on_NextButton_button_down():
	pass # Replace with function body.
