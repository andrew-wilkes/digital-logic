extends Control

var target: int
var number: int
var numbers
var num_type
var num_digits
var dec
var num
var hbin
var vtext
var idx = 0
var warning = false
var alert
var state
var max_num: int

enum { HEX, BIN, PLAYING, CORRECT, NEXT, DONE }

func _ready():
	state = PLAYING
	num = find_node("num")
	dec = find_node("dec")
	hbin = find_node("hbin")
	vtext = find_node("vtext")
	alert = find_node("Alert")
	var data = g.load_file("res://numbers.tsv", false).strip_edges()
	numbers = data.split("\n")
	set_target()


func set_target():
	var data = numbers[idx].split("\t")
	target = int(data[0])
	num.text = data[0]
	if data[1] == "":
		num_type = BIN
		var b = data[2].replace(" ", "")
		num_digits = len(b)
		max_num = int(pow(2, num_digits))
		number = bin2dec(int(b))
		disable_shift_buttons(false)
	else:
		var h = data[1]
		num_type = HEX
		num_digits = len(h)
		max_num = int(pow(16, num_digits))
		number = ("0x" + h).hex_to_int()
		disable_shift_buttons()
	set_number(number)
	idx += 1


func set_number(n):
	if n >= max_num:
		n = n - max_num
	if n < 0:
		n = max_num + n
	if num_type == BIN:
		hbin.text = dec2bin(n)
		vtext.text = "Binary:"
		if num_digits > 1 and n > int(max_num / 4.0):
			var neg = n - max_num
			dec.text = "%d (%d)" % [n, neg]
		else:
			dec.text = String(n)
	else:
		var fmt = "%0*X"
		hbin.text = fmt % [num_digits, n]
		vtext.text = "Hexadecimal:"
		dec.text = String(n)
	number = n
	check_number()


func check_number():
	if warning:
		$AlertTimer.start()
	if number == target:
		state = CORRECT
		if not warning:
			alert_correct()


func alert_correct():
		alert.modulate = Color.green
		alert.text = "Correct!"
		warning = true
		state = NEXT
		$AlertTimer.start()


func dec2bin(decimal_value: int):
	var binary_string = "" 
	var temp 
	var count = num_digits - 1 # Checking up to num_digits bits
	var n = 0 # Space counter
	while(count >= 0):
		if n == 4:
			n = 0
			binary_string = binary_string + " "
		temp = decimal_value >> count 
		if(temp & 1):
			binary_string = binary_string + "1"
		else:
			binary_string = binary_string + "0"
		count -= 1
		n += 1
	return binary_string


func bin2dec(binary_value):
	var decimal_value = 0
	var count = 0
	var temp
	while(binary_value != 0):
		temp = binary_value % 10
		binary_value /= 10
		decimal_value += temp * pow(2, count)
		count += 1
	return decimal_value


func _on_Up_button_down():
	change_number(1)


func _on_Down_button_down():
	change_number(-1)


func change_number(delta):
	if warning:
		return
	if num_digits > 1 or num_type == HEX:
		check_overflows(delta)
	set_number(number + delta)


func check_overflows(delta):
	if delta == 1:
		alert.modulate = Color.red
		if num_type == BIN:
			if number == int(max_num / 2.0) - 1:
				alert.text = "Signed overflow"
				warning = true
			if number == max_num - 1:
				alert.text = "Unsigned overflow"
				warning = true
		else:
			if number == max_num - 1:
				alert.text = "Overflow"
				warning = true
	else:
		alert.modulate = Color.yellow
		if num_type == BIN:
			if number == int(max_num / 2.0):
				alert.text = "Signed underflow"
				warning = true
			if number == 0:
				alert.text = "Unsigned underflow"
				warning = true
		else:
			if number == 0:
				alert.text = "Underflow"
				warning = true


func _on_ShiftLeft_button_down():
	set_number(number << 1)


func _on_ShiftRight_button_down():
	set_number(number >> 1)


func _on_Invert_button_down():
	set_number(~number)


func _on_Timer_timeout():
	alert.text = ""
	warning = false
	if state == CORRECT:
		state = PLAYING
		alert_correct()
	if idx == numbers.size():
		alert.text = "Completed!"
		state = DONE
		disable_buttons()
	if state == NEXT:
		state = PLAYING
		set_target()


func disable_buttons(disabled = true):
	for node in get_tree().get_nodes_in_group("control buttons"):
		node.disabled = disabled


func disable_shift_buttons(disabled = true):
	for node in get_tree().get_nodes_in_group("shift buttons"):
		node.disabled = disabled
