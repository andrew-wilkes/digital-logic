extends Control

signal code_error(msg, line_num)
signal edit_source(line_num)

var testing = false
var locs
var line_text
var pc = 0
var lang = 0
var running = false

func _ready():
	locs = $VBox/SC/LOCS # Memory location info (hex value + if there is: line of code)
	init_lines(256)
	if get_parent().name == "root":
		$BG.show()
		g.src = "START: DEST, DEST, ADD\nADD: SRC, TEMP, NEXT\nNEXT: TEMP, DEST, CONT\nCONT: CONT, CONT, CONT\nTEMP:0\nSRC:2\nDEST:3\n:\" abcdefg\"\nX:0 0 X"
		g.clear_memory()
		load_memory()
	else:
		$BG.hide()
	set_pc(0)


func init_lines(num_lines):
	var new_line
	var loc_line = locs.get_child(0)
	for n in num_lines:
		if n == 0:
			new_line = loc_line 
		else:
			new_line = loc_line.duplicate()
			locs.add_child(new_line)
		new_line.get_node("ADDR").text = "%02X" % n
		new_line.get_node("SRC").id = n
		new_line.get_node("SRC").connect("value_changed", self, "set_value")
		new_line.get_node("SRC").connect("clicked", self, "edit_source")


func edit_source(line_number):
	emit_signal("edit_source", line_number)


func load_memory():
	var addr = 0
	for loc in locs.get_children():
		var label = loc.get_node("SRC")
		label.set_values(g.mem[addr], "")
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
				var a = get_next_token()
				if a.is_valid_integer() and line_text.empty(): # Single value line
					addr = inc_addr(addr)
				elif a[0] == '"':
					a = a.replace('"', "")
					addr = inc_addr(addr, a.length())
				else:
					addr = inc_addr(addr, 3)
	addr = 0
	for line in lines:
		line_text = line.code
		var a = get_next_token()
		if a.is_valid_integer() and line_text.empty():
			set_values(addr, int(a), line.number, a, code.pop_front())
			addr = inc_addr(addr)
		elif a[0] == '"':
				a = a.replace('"', "")
				var txt = code.pop_front()
				for ch in a:
					set_values(addr, ord(ch), line.number, ch, txt)
					txt = ""
					addr = inc_addr(addr)
		else:
			if set_int_or_get_value(labels, a, addr, line.number, code.pop_front()):
				return
			addr = inc_addr(addr)
			var b = get_next_token()
			if b == "":
				show_msg("Missing second parameter!", line.number)
				return
			if set_int_or_get_value(labels, b, addr, line.number):
				return
			addr = inc_addr(addr)
			var c = get_next_token()
			if c == "": # Set jump address to next line
				set_values(addr, addr + 1, line.number, "", c)
			elif set_int_or_get_value(labels, c, addr, line.number):
				return
			addr = inc_addr(addr)


func set_int_or_get_value(labels, token, addr, line_number, txt = ""):
	var error = false
	if token.is_valid_integer():
		set_values(addr, int(token), line_number, token, txt)
	else:
		var offset = token.length()
		var stripped_token = token.rstrip("+")
		if labels.keys().has(stripped_token):
			offset -= stripped_token.length()
			set_values(addr, labels[stripped_token] + offset, line_number, token, txt)
		else:
			error = true
			show_msg("Unknown label: %s" % stripped_token, line_number)
	return error


func set_values(addr, v, line_number = 0, token = "", txt = ""):
	if txt == null:
		txt = ""
	var label = locs.get_child(addr).get_node("SRC")
	label.set_values(v, token, txt)
	label.editable = txt.empty()
	label.line_number = line_number
	if addr < g.mem.size():
		g.mem[addr] = v


func get_next_token():
	var txt = line_text.dedent().replace(",", " ")
	var t = txt
	var delim = " "
	if t[0] == '"':
		delim = "\r" # Cause the whole line to be returned
	var i = txt.find(delim)
	if i > 0:
		t = txt.substr(0, i)
		txt = txt.right(i)
	else:
		txt = ""
	line_text = txt
	return t


func set_pc(v):
	set_addr_color(pc, false)
	pc = v
	$VBox/HBox/PCV.text = "%02X" % v
	set_addr_color(pc)


func set_addr_color(n, red = true):
	var addr = locs.get_child(n).get_node("ADDR")
	if red:
		addr.modulate = g.COLOR_HIGH
	else:
		addr.modulate = g.COLOR_UNDEFINED


func set_value(a, v):
	locs.get_child(a).get_node("SRC").set_value(v)
	g.mem[a] = v
	

func inc_addr(addr, n = 1):
	addr += n
	if addr >= g.mem.size():
		addr = g.mem.size() - addr
	return addr


func show_msg(m, line_num = 0):
	emit_signal("code_error", m, line_num)


func _on_Run_button_down():
	if running:
		stop_running()
	else:
		$VBox/HBox/Run.text = "Stop"
		running = true


func stop_running():
	$VBox/HBox/Run.text = "Run"
	running = false


func _on_Step_button_down():
	execute_instruction()


func _on_Reset_button_down():
	stop_running()
	set_pc(0)


func _process(_delta):
	if running:
		execute_instruction()


func execute_instruction():
	match lang:
		0: # SUBLEQ 1-byte address width
			var a = g.mem[pc]
			var b = g.mem[pc + 1]
			var c = g.mem[pc + 2]
			var r = g.mem[b] - g.mem[a] # Negative indexes count from the back
			set_value(b, r)
			if r <= 0:
				set_pc(c)
			else:
				set_pc(pc + 3)
		
		1: # ByteByteJump 3-byte address width
			var add = pc
			var a = get_byte_addr(add)
			add += 3
			var b = get_byte_addr(add)
			add += 3
			g.mem[b] = g.mem[a]
			set_pc(get_byte_addr(add))
		
		2: # ByteByte/Jump 3-byte address width
			var hb = 0x800000
			var add = pc
			var a = get_byte_addr(add)
			if a >= hb:
				set_pc(a - hb)
			else:
				add += 3
				var b = get_byte_addr(add)
				add += 3
				if b >= hb:
					g.mem[b - hb] = g.mem[a]
					g.mem[get_byte_addr(add)] = g.mem[a]
					add += 3
				else:
					g.mem[b] = g.mem[a]
				set_pc(add)


func test_get_byte_addr():
	for n in 4:
		pc = n
		var a = g.mem[pc] * 256
		a += g.mem[pc + 1]
		a *= 256
		a += g.mem[pc + 2]
		var b = get_byte_addr(pc)
		print(a, " ", b)


func get_byte_addr(add: int, n: int = 3, a: int = 0):
	if n > 0:
		a *= 256
		a += g.mem[add]
		add += 1
		a = get_byte_addr(add, n - 1, a)
	return a
	
