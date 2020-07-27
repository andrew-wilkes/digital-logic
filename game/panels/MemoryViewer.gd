extends WindowDialog

const CHR_SIZE = Vector2(10, 22)

var draw_chrs = false
var m_font = preload("res://assets/fonts/mono-font.tres")
var mem = []
var font_col
var testing = false

func _ready():
	if get_parent().name == "root":
		testing = true
		open(mem)


func open(data, title = "Memory Viewer"):
	window_title = title
	mem = data
	font_col = $HBox/VBox2/Hex.get("custom_colors/font_color")
	find_node("Sidebar").text = get_str_range("\n")
	find_node("Header2").text = get_str_range()
	find_node("Header3").text = get_str_range("", "%X")
	draw_chrs = true
	update_data()
	call_deferred("popup_centered")
	$Timer.start()


func update_data():
	if testing:
		set_rand_data()
	find_node("Hex").text = get_str_range(" ", "%02X", 256, true)
	update()


func set_rand_data():
	mem.clear()
	for i in 256:
		var v = randi() % 0xff
		mem.append(v)


func _draw():
	if draw_chrs:
		var c_pos
		var c_origin = $HBox/VBox3.rect_position + Vector2(4, 58)
		var x = 0
		var y = 0
		for n in mem:
			c_pos = c_origin + Vector2(x * CHR_SIZE.x, y * CHR_SIZE.y)
			var ch = "." if n < 32 else char(n)
			# warning-ignore:return_value_discarded
			draw_char(m_font, c_pos, ch, "", font_col)
			x += 1
			if x > 15:
				x = 0
				y += 1


func get_str_range(_chr = " ", _fmt = "%02X", n = 16, from_mem = false):
	var sr: PoolStringArray = []
	for i in n:
		var v = i
		if from_mem:
			v = mem[i]
		sr.append(_fmt % v)
	return sr.join(_chr)


func _on_Timer_timeout():
	update_data()
