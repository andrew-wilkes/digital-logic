extends Part

const TRACE_WIDTH = 180
const TRACE_SIZE = 20
const MIN_TICKS = 3
const MAX_TICKS = 63

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
var num_ticks = 3
var syncing = false
var time = 0
var ticks = 0
var clock_pin = 0

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


func capture():
	if !async:
		count = clock.count
		num_ticks = clock.num_ticks
	if count == 0:
		clear_data()
	var v = 0 
	for i in num_ch:
		data[i].append(inputs[i])
		if i > 0:
			v *= 2
			if inputs[i]:
				v += 1
	samples.append(v)
	slider.max_value = num_ticks + 1
	slider.value = count
	# Ignore initial connection count
	if enabled:
		count += 1
	else:
		enabled = true
	draw_traces()


func set_input(pin, state):
	if pin.state_changed():
		pinclick(pin)
		unstable()
		return
	inputs[pin.id] = state
	if pin.id == clock_pin:
		clock = pin.wires[0].start_pin.parent_part
		async = !clock.has_method("set_rate")
		if async:
			num_ticks = clamp(ticks, MIN_TICKS, MAX_TICKS)
			if ticks == 0: # Start reset timer
				$Timer.start()
			ticks += 1
		call_deferred("capture")


func update_output(_pin, _state, _force = false):
	pass


func clear_data():
	for i in num_ch:
		data[i].clear()
	samples.clear()


func draw_traces():
	if clock:
		step.x = clamp(TRACE_WIDTH / data[0].size(), 0, TRACE_SIZE)
		var y = 0
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
	if value <= num_ticks and value < samples.size():
		$Value.text = "0x%X" % samples[value]


func reset():
	ticks = 0
	count = 0
	clear_data()


func _on_Timer_timeout():
	reset()
