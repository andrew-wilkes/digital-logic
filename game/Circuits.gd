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
var circuit_index = 0
var animate = true
var show_how = true

class GridWire:
	var start_ob
	var end_obs = []
	var members = []
	var state: int = -1 # -1 means the wire state has not been set. Otherwise 0/1
	var changed = 0 # Counter to detect unstable state


func _ready():
	set_circuit(circuit_index)
	init_circuit()


enum { PREV, NEXT, STEP, UNSTABLE } # Events

func sm(event):
	match event:
		PREV:
			circuit_index -= 1
			if circuit_index < 0:
				circuit_index = $VBox/Circuit/c.get_child_count() - 1
			set_circuit(circuit_index)
			init_circuit()
		NEXT:
			circuit_index += 1
			if circuit_index >= $VBox/Circuit/c.get_child_count():
				circuit_index = 0
			set_circuit(circuit_index)
			init_circuit()
		STEP:
			if driven:
				change_pattern_index()
			drive_circuit(pattern_index)
		UNSTABLE:
			$c/Alert.show()


func set_circuit(n):
	for c in $VBox/Circuit/c.get_children():
		c.visible = false
	circuit = $VBox/Circuit/c.get_child(n)
	circuit.visible = true
	animate = true
	$VBox/M2/Details/Title.text = circuit.title


func init_circuit():
	pattern_index = 0
	correct_count = 0
	last_vals = []
	scan_circuit()
	# When first going to this scene in mobile
	# the position setting is off unless we wait
	call_deferred("show_info")


func show_info():
	var info = circuit.get_node("c/Info")
	info.rect_position = rect_position + $VBox.rect_position + $VBox/Circuit.rect_position
	info.rect_size = $VBox/Circuit.rect_size
	if show_how:
		info.show_how()
		show_how = false
	else:
		info.show_notes()
	info.popup()
	if animate:
		info.play_anim()
	if !info.is_connected("popup_hide", self, "_on_Info_popup_hide"):
		info.connect("popup_hide", self, "_on_Info_popup_hide")
	$VBox/HBox/InfoButton.disabled = true


func gate_changed(gate):
	if driven: # Re-evaluate from the changed gate
		correct_count = 0
		for w in wires:
			w.changed = 0 # Reset change counter for all wires
		var unstable = set_outputs(gate.inputs.keys())
		check_correctness(pattern_index)
		if unstable:
			sm(UNSTABLE)
	else:
		# First time to drive the circuit
		drive_circuit(pattern_index)


func change_pattern_index():
	pattern_index += 1
	pattern_index %= num_patterns


# Set up the connectivity between all inputs, gates, and outputs
func scan_circuit():
	inputs = get_inputs()
	for i in inputs:
		i.set_level(-1) # Make white
	outputs = get_outputs()
	for o in outputs:
		o.set_level(-1) # Make white
	last_vals.resize(outputs.size())
	gates = get_gates()
	var white = g.get_state_color(-1)
	wires = get_wire_nets()
	for w in wires:
		for m in w.members:
			m.modulate = white # Make wire white
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
				unstable = set_wire_state(w, 0)
				w.state = -1 # Make all the gates evaluate
	unstable = set_outputs(iws)
	check_correctness(_pattern_index)
	driven = true
	if unstable:
		sm(UNSTABLE)


func check_correctness(_pattern_index):
	if check_outputs(_pattern_index):
		correct_count += 1
		if correct_count >= num_patterns:
			show_tick()
	else:
		correct_count = 0


func set_wire_state(w, v):
	w.state = v
	if w.changed > 2: # Unstable state
		return true
	w.changed += 1
	# Set input color
	if w.start_ob.has_method("set_level"):
		w.start_ob.set_level(v)
	# Set color of wires
	var col = g.get_state_color(v)
	for m in w.members:
		m.modulate = col
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
	# set i to the input value
	for b in circuit.vin[n]:
		i += b * x
		x *= 2
	# scan the outputs and reset 'passed' if any output state does not match required vout value
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
			if (con.position - get_point(line, 0)).length() < 8.0:
				stubs.append(line)
				stub_con[line] = con # Map stub to con
	# Get start wires (wires that are not stubs)
	for line in lines:
		if stubs.has(line):
			continue
		var gw = GridWire.new()
		# Find the part connected to the start of the wire
		gw.start_ob = get_connected_part(get_point(line, 0), gates)
		if gw.start_ob == null:
			gw.start_ob = get_connected_part(get_point(line, 0), inputs)
		else:
			gw.start_ob.output = gw # Ref this wire with the gate's output
		if gw.start_ob == null:
			breakpoint
		# Find the parts connected to the ends of the wires
		var cws = get_connected_wires(line, stubs)
		var members = cws.duplicate()
		members.append(line)
		for member in members:
			var part = get_connected_part(get_point(member, -1), gates)
			if part == null:
				part = get_connected_part(get_point(member, -1), outputs)
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
		var a = get_point(line, n - 1)
		var b = get_point(line, n)
		var vert = near(a.x, b.x)
		for stub in stubs:
			if stub == line:
				continue
			var c = get_point(stub, 0)
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


func get_point(line: Line2D, idx):
	return line.position + line.get_points()[idx]


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
		if !gate.is_connected("changed", self, "gate_changed"):
			gate.connect("changed", self, "gate_changed", [gate])
	return gates


# Check if a node has been accidentally moved, reposition nodes
func check_zero_pos(node):
	var pos = node.rect_position if node is Control else node.position
	if pos.length() > 0.1:
		if node is Control:
			node.rect_position -= pos
		for child in node.get_children():
			if child is Control:
				child.rect_position += pos
			else:
				child.position += pos
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


func _on_InfoButton_button_down():
	show_info()


# Allow for closing the info panel by clicking on the info button
func _on_Info_popup_hide():
	# Need to delay one frame tick to avoid actioning the click on the info
	# button that opens the panel again
	call_deferred("enable_info_button")
	animate = false


func enable_info_button():
	$VBox/HBox/InfoButton.disabled = false
