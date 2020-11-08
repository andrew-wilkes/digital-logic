extends Control

var target
var number
var numbers
var num_type
var num_digits
var dec
var hbin
var vtext
var idx = 0
var warning = false
var alert

enum { HEX, BIN }

func _ready():
	dec = find_node("dec")
	hbin = find_node("hbin")
	vtext = find_node("vtext")
	alert = find_node("Alert")
	var data = g.load_file("res://numbers.tsv", false)
	numbers = data.split("\n")
	set_target()


func set_target():
	var data = numbers[idx].split("\t")
	target = data[0]
	dec.text = String(target)
	if data[1] == "":
		num_type = BIN
		var b = data[2].replace(" ", "")
		num_digits = len(b)
		number = bin2dec(b)
	else:
		var h = data[1]
		num_type = HEX
		num_digits = len(h)
		number = ("0x" + h).hex_to_int()
	set_number(number)


func set_number(n):
	if num_type == BIN:
		hbin.text = dec2bin(n)
		vtext.text = "Binary value:"
	else:
		var fmt = "%0*X"
		hbin.text = fmt % [num_digits, n]
		vtext.text = "Hexadecimal value:"
	number = n


func dec2bin(decimal_value):
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
	if delta == 1:
		alert.modulate = Color.red
		if number == 127:
			alert.text = "Signed overflow"
			warning = true
		if number == 255:
			alert.text = "Unsigned overflow"
			warning = true
	else:
		alert.modulate = Color.yellow
		if number == 128:
			alert.text = "Signed underflow"
			warning = true
		if number == 0:
			alert.text = "Unsigned underflow"
			warning = true
	if warning:
		$AlertTimer.start()
	set_number(number + delta)


func _on_ShiftLeft_button_down():
	set_number(number << 1)


func _on_ShiftRight_button_down():
	set_number(number >> 1)


func _on_Invert_button_down():
	set_number(~number)


func _on_Timer_timeout():
	alert.text = ""
	warning = false
