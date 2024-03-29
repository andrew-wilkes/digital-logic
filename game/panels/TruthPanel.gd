extends AcceptDialog

signal test_button_down

enum { CHECKING_INPUTS, CHECKING_OUTPUTS, CHECKING_TRUTH, FAILED, PASSED }

var state
var circuit
var data
var i
var table
var color
var passed = false
var msg = ""
var ipmap = []
var opmap = []
var x = 0 # Don't care value

func _ready():
	var b = Button.new()
	b.text = "Test"
	b.size_flags_horizontal = 3 # Fill + Expand
	b.connect("button_down", self, "b_pressed")
	var n = get_child(2)
	n.get_child(2).queue_free()
	n.get_child(1).size_flags_horizontal = 3
	n.get_child(0).queue_free()
	n.add_child(b)
	table = $TruthTable


func b_pressed():
	emit_signal("test_button_down")


func open(cid):
	data = tt.data[cid]
	table.populate(data)
	rect_size = Vector2(100, 100)
	popup_centered()


func test_circuit(c):
	circuit = c
	c.get_inputs()
	c.get_outputs()
	clear_grid_colors()
	i = 0
	passed = false
	ipmap = []
	opmap = []
	state = CHECKING_INPUTS
	$Timer.start()


func clear_grid_colors():
	for j in range(data.inputs.size(), table.g1.get_child_count()):
		table.g1.get_child(j).modulate = Color.white
	for j in range(data.outputs.size(), table.g2.get_child_count()):
		table.g2.get_child(j).modulate = Color.white


func _on_Timer_timeout():
	match state:
		CHECKING_INPUTS:
			if passed:
				set_cell_color("g1", i)
				i += 1
				passed = false
			if i == data.inputs.size():
				i = 0
				state = CHECKING_OUTPUTS
			else:
				# Look for named input in circuit
				var s = data.inputs[i]
				var pos = 0 # Index of part containing label
				for ip in circuit.ips:
					if ip.labels.has(s):
						ipmap.append(pos)
						passed = true
						color = get_cell_color("g1", i)
						set_cell_color("g1", i, 0)
						break
					pos += 1
				if !passed:
					state = FAILED
					set_cell_color("g1", i, 1)
					msg = "Missing input: %s" % s
			$Timer.start()
		CHECKING_OUTPUTS:
			if passed:
				set_cell_color("g2", i)
				i += 1
				passed = false
			if i == data.outputs.size():
				i = 0
				state = CHECKING_TRUTH
			else:
				# Look for named output in circuit
				var s = data.outputs[i]
				var pos = 0
				for op in circuit.ops:
					if op.labels.has(s):
						opmap.append(pos)
						passed = true
						color = get_cell_color("g2", i)
						set_cell_color("g2", i, 0)
						break
					pos += 1
				if !passed:
					state = FAILED
					set_cell_color("g2", i, 1)
					msg = "Missing output: %s" % s
			$Timer.start()
		CHECKING_TRUTH:
			if passed:
				i += 1
			if i == data.values.size():
				i = 0
				state = PASSED
			else:
				# Get row of values
				var io = data.values[i]
				# Apply input values
				var isize = data.inputs.size()
				var osize = data.outputs.size()
				var pin_index = 0
				var part_index = 0
				var last_part_index = 0
				for n in isize:
					part_index = ipmap[n]
					if part_index != last_part_index:
						pin_index = 0
						last_part_index = part_index
					circuit.ips[part_index].part.set_state(bool(io[n]), pin_index)
					set_cell_color("g1", isize * i + n + isize, 0)
					pin_index += 1
				# Check output values
				passed = true
				pin_index = 0
				part_index = 0
				last_part_index = 0
				for n in data.outputs.size():
					part_index = opmap[n]
					if part_index != last_part_index:
						pin_index = 0
						last_part_index = part_index
					if bool(io[n + isize]) == circuit.ops[part_index].part.get_state(pin_index):
						set_cell_color("g2", osize * i + n + osize, 0)
					else:
						set_cell_color("g2", osize * i + n + osize, 1)
						passed = false
					pin_index += 1
				if !passed:
					state = FAILED
					msg = "Incorrect logic!"
			$Timer.start()
		FAILED:
			$Msg.window_title = "Failed!"
			$Msg.dialog_text = msg
			$Msg.popup_centered()
			circuit.set_status(2)
		PASSED:
			$Msg.window_title = "Passed!"
			$Msg.dialog_text = ""
			$Msg.popup_centered()
			circuit.set_status(3)


func get_cell_color(grid, index):
	return table[grid].get_child(index).modulate


func set_cell_color(grid, index, c = -1):
	var col = color
	match c:
		0:
			col = g.COLOR_ACTIVE
		1:
			col = g.COLOR_HIGH
	table[grid].get_child(index).modulate = col
