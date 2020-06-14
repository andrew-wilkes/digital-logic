extends Part

var labels =  []
var data = []
var num_ch = 0
var inputs = []
var clock
var count = 0
var traces = []

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


func capture():
	if clock.count == 0:
		clear_data()
	for i in num_ch:
		data[i].append(inputs[i])
	draw_traces()


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
		var step = 20
		var y = 0
		for i in num_ch:
			traces[i].clear_points()
			var x = 0
			var last_v = !data[i][0] # Make sure that we draw a starting segment
			for v in data[i]:
				if v:
					if !last_v:
						traces[i].add_point(Vector2(x, y - step))
					traces[i].add_point(Vector2(x + step, y - step))
				else:
					if last_v:
						traces[i].add_point(Vector2(x, y))
					traces[i].add_point(Vector2(x + step, y))
				last_v = v
				x += step
			y += 30
