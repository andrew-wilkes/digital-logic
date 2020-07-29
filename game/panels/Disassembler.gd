extends Control

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
	if get_parent().name == "root":
		$BG.show()
		g.src = "START: DEST, DEST, ADD\nADD: SRC, TEMP, NEXT\nNEXT: TEMP, DEST, CONT\nCONT:w12\nTEMP:w1\nSRC:w2\nDEST:w3"
	else:
		$BG.hide()
	compile()


func update_addresses():
	for n in 256:
		pass


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
				show_msg("Error on line %d: %s" % [line_num, line])
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
					show_msg("Error on line %d: %s (too short)" % [line_num, line])
					return
				line = line.substr(i + 1, end - 1)
				lines.append(line)
				if line[0] == "w":
					addr += 1
				elif line[0] == " ":
					addr += 3
				else:
					show_msg("Error on line %d: %s (no space after colon)" % [line_num, line])
					return
	addr = 0
	for line in lines:
		line_text = line
		if line_text[0] == "w":
			line_text[0] = " "
			var x = get_next_token()
			if x.is_valid_integer():
				set_value(addr, int(x), code.pop_front())
				addr += 1
			else:
				show_msg("Invalid integer: %s" % x)
				return
		else:
			var a = get_next_token()
			if labels.keys().has(a):
				set_value(addr, labels[a], code.pop_front())
			else:
				show_msg("Unknown label: %s" % a)
				return
			addr += 1
			var b = get_next_token()
			if b == "":
				show_msg("Missing second parameter!")
				return
			if labels.keys().has(b):
				set_value(addr, labels[b], b)
			else:
				show_msg("Unknown label: %s" % b)
				return
			addr += 1
			var c = get_next_token()
			if c == "":
				set_value(addr, labels[b], b)
			elif labels.keys().has(c):
				set_value(addr, labels[c], c)
			else:
				show_msg("Unknown label: %s" % c)
				return
			addr += 1


func set_value(addr, v, txt = ""):
	print(txt)
	var label = locs.get_child(addr).get_node("SRC")
	label.set_value(v, txt)
	label.editable = txt.empty()
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


func show_msg(m):
	print(m)
	#msg.dialog_text = m
	#msg.popup_centered()
