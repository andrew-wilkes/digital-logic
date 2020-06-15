extends Part

const TRACE_SIZE = 20

var labels =  []
var data = []
var num_ch = 0
var inputs = []
var clock
var traces = []
var slider
var samples = [0, 0]
var marker
var step = Vector2(TRACE_SIZE, TRACE_SIZE)

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
	if clock.count == 0:
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
	draw_traces()
	slider.max_value = clock.num_ticks + 1
	slider.value = clock.count


func update_output(pin, value):
	if pin.id == 0:
		var src = pin.wires[0].start_pin.parent_part
		if clock != src:
			if clock:
				clock.disconnect("clock", self, "capture")
			clock = src
			clock.connect("clock", self, "capture")
	inputs[pin.id] = value


func clear_data():
	for i in num_ch:
		data[i].clear()


func draw_traces():
	if clock:
		step.x = clamp(TRACE_SIZE * 8 / clock.num_ticks, 0, 40)
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
	if value <= clock.num_ticks and value < samples.size():
		$Value.text = "%X" % samples[value]
