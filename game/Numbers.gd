extends Panel

var number = 0
var delta = 0
var alert
var counter
var warning = false

func _ready():
	alert = find_node("Alert")
	alert.text = ""
	counter = find_node("Counter")
	set_number(0)


func set_number(n):
	n %= 256
	if n < 0:
		n = 256 + n
	set_binary(n)
	set_hex(n)
	set_unsigned_decimal(n)
	set_signed_decimal(n)
	number = n


func set_binary(n):
	set_text(0, dec2bin(n))


func set_hex(n):
	set_text(1, "%02X" % n)


func set_unsigned_decimal(n):
	set_text(2, "%3d" % n)


func set_signed_decimal(n):
	if n > 127:
		n = n - 256
	set_text(3, "%4d" % n)


func set_text(i, txt):
	counter.get_child(i).get_child(1).text = txt


func dec2bin(var decimal_value):
	var binary_string = "" 
	var temp 
	var count = 7 # Checking up to 8 bits 
	while(count >= 0):
		temp = decimal_value >> count 
		if(temp & 1):
			binary_string = binary_string + "1"
		else:
			binary_string = binary_string + "0"
		count -= 1
	return binary_string


func _on_Up_button_down():
	delta = 1
	change_number()
	$Timer.start(0.5)


func _on_Up_button_up():
	$Timer.stop()
	delta = 0


func _on_Down_button_down():
	delta = -1
	change_number()
	$Timer.start(0.5)


func _on_Down_button_up():
	$Timer.stop()
	delta = 0


func _on_Timer_timeout():
	change_number()
	$Timer.start(0.05)


func change_number():
	if warning:
		return
	if delta == 1:
		if number == 127:
			alert.text = "Signed overflow"
			alert.modulate = Color.yellow
			warning = true
		if number == 255:
			alert.text = "Unsigned overflow"
			alert.modulate = Color.red
			warning = true
	else:
		if number == 128:
			alert.text = "Signed underflow"
			alert.modulate = Color.yellow
			warning = true
		if number == 0:
			alert.text = "Unsigned underflow"
			alert.modulate = Color.red
			warning = true
	if warning:
		$AlertTimer.start()
	set_number(number + delta)


func _on_AlertTimer_timeout():
	alert.text = ""
	warning = false
