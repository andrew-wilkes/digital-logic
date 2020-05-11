extends Control

var g1
var g2
var ni
var no

func _ready():
	g1 = find_node("Grid")
	g2 = find_node("Grid2")
	var data = {
		inputs = ["A2","A1","A0"],
		outputs = ["Y0","Y1","Y2","Y3","Y4","Y5","Y6","Y7"],
		values = [
			[0,0,0,1,0,0,0,0,0,0,0],
			[0,0,1,0,1,0,0,0,0,0,0],
			[0,1,0,0,0,1,0,0,0,0,0],
			[0,1,1,0,0,0,1,0,0,0,0],
			[1,0,0,0,0,0,0,1,0,0,0],
			[1,0,1,0,0,0,0,0,1,0,0],
			[1,1,0,0,0,0,0,0,0,1,0],
			[1,1,1,0,0,0,0,0,0,0,1]
		]
	}
	populate(data)


func populate(data):
	ni = data.inputs.size()
	g1.columns = ni
	no = data.outputs.size()
	g2.columns = no
	for h in data.inputs:
		add_label(g1, h, Color.yellow)
	for h in data.outputs:
		add_label(g2, h, Color.greenyellow)
	for row in data.values:
		for i in ni:
			add_label(g1, row[i])
		for i in no:
			add_label(g2, row[i + ni])


func add_label(g, txt, color = Color.white):
	var l = Label.new()
	l.text = String(txt)
	l.align = Label.ALIGN_CENTER
	l.modulate = color
	g.add_child(l)
