extends Control

var inputs = []
var outputs = []
var gates = []
var wires = []
var pattern_index = 0
var num_patterns = 0
var correct_count = 0
var driven = false
var last_vals = []
var circuit

class GridWire:
	var start_ob
	var end_obs = []
	var members = []
	var state = false
	var changed = 0 # Counter to detect unstable state


func _ready():
	circuit = $VBox/Circuit.get_child(0)
	sm(NEXT)


enum { PREV, NEXT, STEP, UNSTABLE } # Events

func sm(event):
	match event:
		PREV:
			init_circuit()
		NEXT:
			init_circuit()
		STEP:
			if driven:
				change_pattern_index()
			drive_circuit(pattern_index)
		UNSTABLE:
			$c/Unstable.popup_centered()


func init_circuit():
	scan_circuit()
	$c/Info/VBox/BG/M/Notes.text = circuit.info
	$c/Info.popup_centered()


func gate_changed(gate):
	if driven: # Re-evaluate from the changed gate
		correct_count = 0
		for w in wires:
			w.changed = 0 # Reset change counter for all wires
		set_outputs(gate.inputs.keys())
		check_correctness(pattern_index)
	else:
		# First time to drive the circuit
		drive_circuit(pattern_index)


func change_pattern_index():
	pattern_index += 1
	pattern_index %= num_patterns


# Set up the connectivity between all inputs, gates, and outputs
func scan_circuit():
	# Connect inputs to gates
	inputs = get_inputs()
	outputs = get_outputs()
	last_vals.resize(outputs.size())
	gates = get_gates()
	wires = get_wire_nets()
	num_patterns = circuit.vin.size()
	driven = false


func drive_circuit(_pattern_index):
	# Get input wires
	var iws = []
	var unstable = false
	var pattern = circuit.vin[_pattern_index].duplicate()
	for w in wires:
		w.changed = 0 # Reset change counter for all wires
		if w.start_ob is GridInput:
			iws.append(w)
			var state = pattern.pop_front()
			unstable = set_wire_state(w, state)
		else:
			if !driven: # Change color from white
				unstable = set_wire_state(w, false)
	unstable = set_outputs(iws)
	check_correctness(_pattern_index)
	if unstable:
		sm(UNSTABLE)


func check_correctness(_pattern_index):
	if check_outputs(_pattern_index):
		correct_count += 1
		if correct_count >= num_patterns:
			show_tick()
	else:
		correct_count = 0
	driven = true


func set_wire_state(w, v):
	w.state = v
	if w.changed > 2: # Unstable state
		return true
	w.changed += 1
	# Set input color
	if w.start_ob.has_method("set_level"):
		w.start_ob.set_level(v)
	# Set color of wires
	for m in w.members:
		m.modulate = g.get_state_color(v)
	# Assign wire to gate inputs
	for g in w.end_obs:
		g.inputs[w] = v
		if g.has_method("set_level"):
			g.set_level(v)
	return false


func set_outputs(gws):
	var unstable = false
	if len(gws) < 1:
		return
	var next_wires = []
	for w in gws:
		for ob in w.end_obs:
			if ob is GridGate:
				# Set the state of the gate's output wire
				var v = ob.eval_inputs()
				if ob.output.state != v:
					unstable = set_wire_state(ob.output, v)
					if unstable:
						return unstable
					next_wires.append(ob.output)
			else:
				# Set output pin level
				ob.set_level(w.state)
	unstable = set_outputs(next_wires)
	return unstable


func check_outputs(n):
	var passed = true
	# Get index of output state from input pattern
	var i = 0
	var x = 1
	for b in circuit.vin[n]:
		i += b * x
		x *= 2
	for j in outputs.size():
		var val = circuit.vout[i][j]
		if val == 2: # Use remembered last value
			val = 0 if last_vals[j] == null else last_vals[j]
		else:
			last_vals[j] = val
		var v = outputs[j].state == bool(val)
		if !v:
			passed = false
		outputs[j].set_result(v)
	return passed


func get_inputs():
	return check_zero_pos(circuit.get_node("In")).get_children()


func get_outputs():
	return check_zero_pos(circuit.get_node("Out")).get_children()


func get_wire_nets():
	var gws = []
	var lines = []
	var cons = get_cons()
	var stubs = []
	var stub_con = {}
	for node in circuit.get_children():
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
		if gw.start_ob == null:
			breakpoint
		# Find the parts connected to the ends of the wires
		var cws = get_connected_wires(line, stubs)
		var members = cws.duplicate()
		members.append(line)
		for member in members:
			var part = get_connected_part(member.get_points()[-1], gates)
			if part == null:
				part = get_connected_part(member.get_points()[-1], outputs)
			gw.end_obs.append(part)
			if part == null:
				breakpoint
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
	return check_zero_pos(circuit.get_node("Con")).get_children()


func get_gates():
	gates = check_zero_pos(circuit.get_node("Gates")).get_children()
	for gate in gates:
		gate.set_to_obscured() # Change all the 2-input gates to XOR
		gate.connect("changed", self, "gate_changed", [gate])
	return gates


func check_zero_pos(node):
	if node is Control:
		if node.rect_position.length() > 0.1:
			breakpoint;
	else:
		if node.position.length() > 0.1:
			breakpoint;
	return node


func get_connected_part(point: Vector2, items: Array):
	for gate in items:
		if (gate.rect_position - point).length() < 65.0:
			return gate


func _on_Step_button_down():
	sm(STEP)


func _on_PreviousButton_button_down():
	sm(PREV)


func _on_NextButton_button_down():
	sm(NEXT)


func _on_Tick_Timer_timeout():
	$c/Tick.hide()


func show_tick():
	$c/Tick.popup_centered()
	$TickTimer.start()
