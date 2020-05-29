extends AcceptDialog

signal test_button_down

enum { CHECKING_INPUTS, CHECKING_OUTPUTS, CHECKING_TRUTH, FAILED }

var state
var circuit
var data
var checked
var i
var table
var color
var passed = false
var msg = ""

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
	checked = false
	i = 0
	passed = false
	state = CHECKING_INPUTS
	$Timer.start()


func _on_Timer_timeout():
	match state:
		CHECKING_INPUTS:
			if passed:
				table.g1.get_child(i).modulate = color
				i += 1
				passed = false
			if i == data.inputs.size():
				i = 0
				state = CHECKING_OUTPUTS
			else:
				# Look for named input in circuit
				var s = data.inputs[i]
				for ip in circuit.ips:
					if ip.get_label() == s:
						passed = true
						color = table.g1.get_child(i).modulate
						table.g1.get_child(i).modulate = g.COLOR_ACTIVE
						break
				if !passed:
					state = FAILED
					table.g1.get_child(i).modulate = g.COLOR_HIGH
					msg = "Missing input: %s" % s
			$Timer.start()
		CHECKING_OUTPUTS:
			if passed:
				table.g2.get_child(i).modulate = color
				i += 1
				passed = false
			if i == data.outputs.size():
				i = 0
				state = CHECKING_TRUTH
			else:
				# Look for named output in circuit
				var s = data.outputs[i]
				for op in circuit.ops:
					if op.get_label() == s:
						passed = true
						color = table.g2.get_child(i).modulate
						table.g2.get_child(i).modulate = g.COLOR_ACTIVE
						break
				if !passed:
					state = FAILED
					table.g2.get_child(i).modulate = g.COLOR_HIGH
					msg = "Missing output: %s" % s
			$Timer.start()
		CHECKING_TRUTH:
			pass
		FAILED:
			$Msg.dialog_text = msg
			$Msg.popup_centered()
