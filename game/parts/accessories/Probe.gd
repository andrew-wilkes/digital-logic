extends Part

const TRACE_SIZE = 20
const NUM_ASYNC_SAMPLES = 16

var labels =  []
var data = []
var num_ch = 0
var clock : Node2D
var traces = []
var slider	
var samples = [0, 0]
var marker
var step = Vector2(TRACE_SIZE, TRACE_SIZE)
var async = true
var count = 0
var enabled = false

func _ready():
	allow_testing()
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Inputs.get_children():
		node.id = i
		connect_pin(node)
		i += 1
		data.append([])
		inputs.append(false)
	num_ch = i
	traces = $Traces.get_children()
	slider = $Slider
	marker = $Marker/Line
	yield(get_tree().create_timer(0.2), "timeout")
	set_input($Inputs.get_child(0), inputs[0]) # Make traces match input levels of loaded scene


func capture():
	if !async:
		count = clock.count
	if count == 0:
		clear_data()
		samples.clear()
	var v = 0 
	for i in num_ch:
		data[i].append(inputs[i])
		if i > 0:
			v *= 2
			if inputs[i]:
				v += 1
	samples.append(v)
	if !async:
		slider.max_value = clock.num_ticks + 1
		print(count, " ", inputs[0])
	slider.value = count
	draw_traces()


func set_input(pin, state):
	if !enabled: # Ignore initial connection
		enabled = true
		return
	if pin.state_changed():
		pinclick(pin)
		unstable()
		return
	inputs[pin.id] = state
	if pin.id == 0:
		print("Pin: ", state)
		clock = pin.wires[0].start_pin.parent_part
		async = !clock.has_method("set_rate")
		capture()
		if async:
			slider.max_value = NUM_ASYNC_SAMPLES
			count += 1
			if count == NUM_ASYNC_SAMPLES:
				count = 0


func update_output(_pin, _state, _force = false):
	pass


func clear_data():
	for i in num_ch:
		data[i].clear()


func draw_traces():
	if clock:
		step.x = clamp(TRACE_SIZE * 8 / clock.num_ticks, 0, 40)
		var y = 0
		print(data[0])
		for i in num_ch:
			traces[i].clear_points()
			var x = 0
			var last_v = !data[i][0] # Make sure that we draw a starting segment
			for v in data[i]:
				if v:
					if !last_v:
						traces[i].add_point(Vector2(x, y - step.y))
					traces[i].add_point(Vector2(x + step.x, y - step.y))
				else:
					if last_v:
						traces[i].add_point(Vector2(x, y))
					traces[i].add_point(Vector2(x + step.x, y))
				last_v = v
				x += step.x


func _on_Slider_value_changed(value):
	marker.position.x = value * step.x
	if value <= clock.num_ticks and value < samples.size():
		$Value.text = "0x%X" % samples[value]
