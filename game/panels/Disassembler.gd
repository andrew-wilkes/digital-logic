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
		g.mem.resize(256 * 4)
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
				if end - i < 2:
					show_msg("Error on line %d: %s (too short)" % [line_num, line], line_num)
					return
				line = line.substr(i + 1, end - 1)
				lines.append({"code": line, "number": line_num})
				line_text = line
				var x = get_next_token()
				if x.is_valid_integer():
					addr = inc_addr(addr)
				else:
					addr = inc_addr(addr, 3)
	addr = 0
	for line in lines:
		line_text = line.code
		var a = get_next_token()
		if a.is_valid_integer():
			set_value(addr, int(a), line.number, a, code.pop_front())
			addr = inc_addr(addr)
		else:
			if a[0] == "\"":
				for ch in a:
					if ch != "\"":
						set_value(addr, ord(ch), line.number, ch)
						addr = inc_addr(addr)
				code.pop_front()
			else:
				if set_int_or_get_value(labels, a, addr, line.number, code.pop_front()):
					return
				addr = inc_addr(addr)
				var b = get_next_token()
				if b == "":
					show_msg("Missing second parameter!", line.number)
					return
				if set_int_or_get_value(labels, b, addr, line.number, b):
					return
				addr = inc_addr(addr)
				var c = get_next_token()
				if c == "": # Set jump address to next line
					set_value(addr, addr + 1, line.number, "", c)
				elif set_int_or_get_value(labels, c, addr, line.number, c):
					return
				addr = inc_addr(addr)


func set_int_or_get_value(labels, token, addr, line_number, txt):
	var error = false
	if token.is_valid_integer():
		set_value(addr, int(token), line_number, token)
	else:
		var offset = token.length()
		var stripped_token = token.rstrip("+")
		if labels.keys().has(stripped_token):
			offset -= stripped_token.length()
			set_value(addr, labels[stripped_token] + offset, line_number, token, txt)
		else:
			error = true
			show_msg("Unknown label: %s" % stripped_token, line_number)
	return error


func set_value(addr, v, line_number = 0, token = "", txt = ""):
	var label = locs.get_child(addr).get_node("SRC")
	label.set_value(v, token, txt)
	label.editable = txt.empty()
	label.line_number = line_number
	if addr < g.mem.size():
		g.mem[addr] = v


func get_next_token():
	var txt = line_text.dedent().replace(",", " ")
	var t = txt
	var i = txt.find(" ")
	if i > 0:
		t = txt.substr(0, i)
		txt = txt.right(i)
	else:
		txt = ""
	line_text = txt
	return t


func inc_addr(addr, n = 1):
	addr += n
	if addr >= g.mem.size():
		addr = g.mem.size() - addr
	return addr


func show_msg(m, line_num = 0):
	emit_signal("code_error", m, line_num)


func _on_Run_button_down():
	pass # Replace with function body.


func _on_Step_button_down():
	pass # Replace with function body.


func _on_Reset_button_down():
	pass # Replace with function body.
