extends Control

signal code_error(msg, line_num)
signal edit_source(line_num)

var testing = false
var locs
var line_text

func _ready():
	locs = $VBox/SC/LOCS # Memory location info (hex value + if there is: line of code)
	var loc_line = locs.get_child(0)
	var new_line
	for n in 256:
		if n == 0:
			new_line = loc_line 
		else:
			new_line = loc_line.duplicate()
			locs.add_child(new_line)
		new_line.get_node("ADDR").text = "%02X" % n
		new_line.get_node("SRC").id = n
		new_line.get_node("SRC").connect("value_changed", self, "set_value")
		new_line.get_node("SRC").connect("clicked", self, "edit_source")
	if get_parent().name == "root":
		$BG.show()
		g.src = "START: DEST, DEST, ADD\nADD: SRC, TEMP, NEXT\nNEXT: TEMP, DEST, CONT\nCONT:w12\nTEMP:w1\nSRC:w2\nDEST:w3"
		compile()
	else:
		$BG.hide()


func edit_source(line_number):
	emit_signal("edit_source", line_number)


func load_memory():
	var addr = 0
	for loc in locs.get_children():
		var label = loc.get_node("SRC")
		label.set_value(g.mem[addr], "")
		label.editable = true
		label.line_number = 0
		addr += 1
	compile()


func compile():
	var src = g.src.replace("\t", " ")
	var code = []
	# Remove comments and blank lines
	# Extract labels and the corresponding address
	var lines = []
	var labels = {}
	var addr = 0
	var line_num = 0
	for line in src.split("\n"):
		line_num += 1
		line.lstrip(" ")
		if line.length() > 0 and line[0] != "#":
			var i = line.find(":")
			if i < 0:
				show_msg("Error on line %d: %s" % [line_num, line], line_num)
				return
			else:
				var label = line.substr(0, i).dedent().rstrip(" ")
				if label.length() > 0:
					labels[label] = addr
				line = line.rstrip(" ")
				code.append(line)
				var end = line.find("#") # Look for end comment
				if end < 1:
					end = line.length()
				if end - i < 3:
					show_msg("Error on line %d: %s (too short)" % [line_num, line], line_num)
					return
				line = line.substr(i + 1, end - 1)
				lines.append({"code": line, "number": line_num})
				if line[0] == "n":
					addr += 1
				elif line[0] == " ":
					addr += 3
				else:
					show_msg("Error on line %d: %s (no space after colon)" % [line_num, line], line_num)
					return
	addr = 0
	for line in lines:
		line_text = line.code
		if line_text[0] == "n":
			line_text[0] = " "
			var x = get_next_token()
			if x.is_valid_integer():
				set_value(addr, int(x), line.number, code.pop_front())
				addr += 1
			else:
				show_msg("Invalid integer: %s" % x, line.number)
				return
		else:
			var a = get_next_token()
			if labels.keys().has(a):
				set_value(addr, labels[a], line.number, code.pop_front())
			else:
				show_msg("Unknown label: %s" % a, line.number)
				return
			addr += 1
			var b = get_next_token()
			if b == "":
				show_msg("Missing second parameter!", line.number)
				return
			if labels.keys().has(b):
				set_value(addr, labels[b], line.number, b)
			else:
				show_msg("Unknown label: %s" % b, line.number)
				return
			addr += 1
			var c = get_next_token()
			if c == "":
				set_value(addr, labels[b], line.number, b)
			elif labels.keys().has(c):
				set_value(addr, labels[c], line.number, c)
			else:
				show_msg("Unknown label: %s" % c, line.number)
				return
			addr += 1


func set_value(addr, v, line_number = 0, txt = ""):
	var label = locs.get_child(addr).get_node("SRC")
	label.set_value(v, txt)
	label.editable = txt.empty()
	label.line_number = line_number
	if addr < g.mem.size():
		g.mem[addr] = v


func get_next_token():
	var txt = line_text.dedent().replace(",", "")
	var t = txt
	var i = txt.find(" ")
	if i > 0:
		t = txt.substr(0, i)
		txt = txt.right(i)
	else:
		txt = ""
	line_text = txt
	return t


func show_msg(m, line_num = 0):
	emit_signal("code_error", m, line_num)
