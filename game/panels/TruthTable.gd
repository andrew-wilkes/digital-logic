extends Control

var g1
var g2
var ni
var no

func _ready():
	g1 = find_node("Grid")
	g2 = find_node("Grid2")
	if get_parent().name == "root":
		var data = tt.data.values()[0]
		populate(data)
		var ok = check_truth(data.values, [
				[0,0,0,1,0,0,1,0,0,0,0],
				[0,0,1,0,1,0,0,0,0,0,0],
				[0,1,0,0,0,1,0,0,0,0,0],
				[0,1,1,0,0,0,1,0,0,0,0],
				[1,0,0,0,0,0,0,1,0,0,0],
				[1,0,1,0,0,0,0,0,1,0,0],
				[1,1,0,0,0,0,0,0,0,1,0],
				[1,1,1,0,0,0,0,0,0,0,1]
			])


func check_truth(values, map):
	var ok = true
	var n = 0
	for row in map:
		for i in no:
			var v1 = values[n][i + ni]
			var v2 = row[i + ni]
			if v1 is String:
				set_output(n, i, v2)
			elif v1 != v2:
				set_output(n, i, v2, Color.red)
				ok = false
			else:
				set_output(n, i, v2, Color.green)
		n += 1
	return ok


func set_output(row, col, txt, color = Color.white):
	var l = g2.get_child(row * no + col + no)
	l.text = String(txt)
	l.modulate = color


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


func clear():
	clear_grid(g1)
	clear_grid(g2)


func clear_grid(g):
	for n in g.get_children():
		n.queue_free()
