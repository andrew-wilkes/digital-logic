extends Control

var target: int
var number: int
var step: int
var target_step: int
var numbers
var num_digits = 1 # Number of bits
var num_type
var labels
var values
var desc
var idx = 0
var last_idx = 0
var warning = false
var alert
var state
var max_num: int
var mode = 0
var level = 0
var dec = "Base 10 value"
var animate = true
export(String, MULTILINE) var n1 # Number data
export(String, MULTILINE) var n2
var mode_text = [
	"Play with the buttons",
	"Match the number",
	"Match binary to hex"
]
enum { INC, RAND }
var step_mode = INC

# Reset button mode
enum { BACK, START, RND }
var reset_mode = RND

# Number (target), hex, bin, base10 (number entered), not used
enum { NUM, HEX, BIN, DEC, NULL, THEX, STEP }
var op_maps = [[3, 1, 2], [0, 1, 6], [5, 2, 6]]
var label_text = ["Number:", "Hex:", "Binary:", "Base10:", "", "Hex:", "Steps:"]

enum { PLAY, TRAIN, CHALLENGE } # Modes
enum { PLAYING, CORRECT, DONE } # States
enum { PLUS, MINUS, LEFT, RIGHT, INVERT, ATIMEOUT, MODE, LEVEL, RESET, SAVE } # Events

func _ready():
	dec = ""
	state = PLAYING
	mode = PLAY
	desc = find_node("Desc")
	labels = find_node("Labels")
	values = find_node("Values")
	alert = find_node("Alert")
	set_mode()


func get_data(txt: String):
	return txt.strip_edges().split("\n")


func sm(event):
	match event:
		MODE:
			mode += 1
			mode %= 3
			set_mode()
		LEVEL:
			if state == DONE:
				return
			level += 1
			level %= 4
			if level < 3:
				set_level(level)
			else:
				set_level(4 - level)
	alert.text = ""
	if mode == PLAY:
		play_sm(event)
	else:
		challenge_sm(event)


func play_sm(event):
	match state:
		PLAYING:
			match event:
				INVERT:
					set_number(~number)
				LEFT:
					set_number(number << 1)
				RIGHT:
					set_number(number >> 1)
				PLUS:
					set_number(number + 1)
				MINUS:
					set_number(number - 1)
				RESET:
					set_number(0)


func challenge_sm(event):
	if state == DONE:
		if event == RESET:
			disable_control_buttons(false)
		else:
			return
	match event:
		RESET:
			match reset_mode:
				BACK:
					idx = last_idx
					if step_mode == INC:
						if idx > 0:
							reset_mode = START
						else:
							reset_mode = RND
				START:
					idx = 0
					reset_mode = RND
				RND:
					show_alert("Random mode")
					step_mode = RAND
					reset_mode = BACK
					idx = randi() % numbers.size()
			set_nums(numbers[idx])
			set_number(number)
			state = PLAYING
	match state:
		PLAYING:
			match event:
				INVERT:
					step -= 1
					set_number(~number)
					check_number()
				LEFT:
					step -= 1
					set_number(number << 1)
					check_number()
				RIGHT:
					step -= 1
					set_number(number >> 1)
					check_number()
				PLUS:
					step -= 1
					# Change the number and check for overflows
					change_number(1)
					check_number()
				MINUS:
					step -= 1
					change_number(-1)
					check_number()
				ATIMEOUT:
					alert.text = ""
					warning = false
		CORRECT:
			match event:
				ATIMEOUT:
					if warning:
						warning = false
						alert_correct()
					else:
						next_number()


func next_number():
	last_idx = idx
	reset_mode = BACK
	if step_mode == INC:
		idx += 1
		if idx == numbers.size():
			alert.text = "Completed!"
			state = DONE
			reset_mode = START
			disable_control_buttons()
			return
	else:
		idx = randi() % numbers.size()
	alert.text = ""
	set_nums(numbers[idx])
	state = PLAYING


func set_mode():
	step_mode = INC
	reset_mode = START
	desc.text = mode_text[mode]
	animate = true
	call_deferred("show_info")
	# Set the label text
	for i in 3:
		labels.get_child(i).text = label_text[op_maps[mode][i]]
	match mode:
		PLAY:
			set_nums("8		1000	0")
		TRAIN:
			numbers = get_data(n1)
			challenge_sm(RESET)
			# idx = numbers.size() - 1 # Test DONE state
		CHALLENGE:
			numbers = get_data(n2)
			challenge_sm(RESET)


# Set the target, start value, and deduce BIN/HEX and number of digits
# Data format: Dec_Number\tStart_Hex_Number\tTarget number of steps\t# Optional comment
# Data format: Dec_Number\t\tBinary_Number\tTarget number of steps\t# Optional comment
# Hex numbers: 0 - ffff
# Binary numbers (treated as int after removing spaces): 0 - 1111 1111 1111 1111
func set_nums(nums):
	var data = nums.split("\t") # Tab separator
	target = int(data[0]) # Target decimal number
	var v = data[1]
	if v == "":
		# Start based off a binary number
		num_type = BIN # Used when checking for overflow
		if mode == TRAIN:
			op_maps[mode][1] = BIN
		var b = data[2].replace(" ", "")
		number = bin2dec(int(b))
		target_step = int(data[3])
		step = target_step
		set_level(int((len(b) - 1) / 4.0))
		disable_shift_buttons(false)
	else:
		# Start based off a hex number
		num_type = HEX
		if mode == TRAIN:
			op_maps[mode][1] = HEX
		number = ("0x" + v).hex_to_int()
		target_step = int(data[2])
		step = target_step
		set_level(int(len(v) / 2.0))
		disable_shift_buttons(mode == TRAIN)


func set_number(n):
	if n >= max_num:
		n = n - max_num
	if n < 0:
		n = max_num + n
	# Set the number labels
	var v = "Number"
	for i in 3:
		var node = values.get_child(i)
		match op_maps[mode][i]:
			NUM:
				v = String(target)
			BIN:
				if i == 2:
					node.modulate = Color.white
				labels.get_child(i).text = label_text[BIN]
				v = dec2bin(n)
			HEX:
				v = set_hex(i, n)
			THEX: # Hex number in place of the decimal number i = 0
				v = set_hex(i, target)
			DEC:
				if num_digits > 1 and n >= int(max_num / 2.0):
					var neg = n - max_num
					v = "%d (%d)" % [n, neg]
				else:
					v = String(n)
			NULL:
				v = ""
			STEP:
				if step < -target_step / 2.0:
					node.modulate = Color.red
				elif step < 0:
					node.modulate = Color.orange
				else:
					node.modulate = Color.green
				v = String(step)
		node.text = v
	number = n


func set_hex(i, n):
	labels.get_child(i).text = label_text[HEX]
	var fmt = "%0*X"
	return fmt % [get_num_hex_digits(num_digits), n]


func set_level(n: int):
	var lbs = get_tree().get_nodes_in_group("level buttons")
	for i in 3:
		lbs[i].visible = i == n
	num_digits = 4 * pow(2, n)
	max_num = int(pow(2, num_digits))
	set_number(int(number) & max_num - 1)


func get_num_hex_digits(n):
	return int((n - 1) / 4.0 + 1)


func test_get_num_hex_digits():
	for n in range(1, 17):
		print(n, " ", get_num_hex_digits(n))


func check_number():
	if warning:
		$AlertTimer.start()
	if target < 0 and number - max_num == target or number == target:
		state = CORRECT
		if not warning:
			alert_correct()


func alert_correct():
	show_alert("Correct!", Color.green)


func show_alert(txt, col = Color.yellow):
	alert.modulate = col
	alert.text = txt
	$AlertTimer.start()


func dec2bin(decimal_value: int) -> String:
	var binary_string = "" 
	var temp 
	var count: int = num_digits - 1 # Checking up to num_digits bits
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


func bin2dec(binary_value: int) -> int:
	var decimal_value = 0
	var count = 0
	var temp
	while(binary_value != 0):
		temp = binary_value % 10
		binary_value /= 10
		decimal_value += temp * pow(2, count)
		count += 1
	return decimal_value


func change_number(delta):
	if warning:
		return
	if num_digits > 1 or num_type == HEX:
		check_overflows(delta)
	set_number(number + delta)


func disable_control_buttons(disabled = true):
	for node in get_tree().get_nodes_in_group("control buttons"):
		disable_button(node, disabled)


func disable_shift_buttons(disabled = true):
	for node in get_tree().get_nodes_in_group("shift buttons"):
		disable_button(node, disabled)


func disable_button(node, disabled):
	node.disabled = disabled
	if disabled:
		node.modulate.a = 0.5
	else:
		node.modulate.a = 1.0


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


func _on_Up_button_down():
	sm(PLUS)


func _on_Down_button_down():
	sm(MINUS)


func _on_ShiftLeft_button_down():
	sm(LEFT)


func _on_ShiftRight_button_down():
	sm(RIGHT)


func _on_Invert_button_down():
	sm(INVERT)


func _on_Mode_button_down():
	sm(MODE)


func _on_Level_button_down():
	sm(LEVEL)


func _on_Reset_button_down():
	sm(RESET)


func _on_Save_button_down():
	sm(SAVE)


func _on_Timer_timeout():
	sm(ATIMEOUT)


func _on_Info_button_down():
	show_info()


func _on_Info_popup_hide():
	call_deferred("enable_info_button")


func enable_info_button():
	$VBox/Control2/Info.disabled = false


func show_info():
	if state == DONE:
		return
	var info = $c/Info
	info.rect_position = $VBox.rect_position + $VBox/Alert.rect_position
	info.rect_position.x = 0
	info.rect_size.x = rect_size.x
	info.rect_size.y = $VBox/Sp2.rect_position.y - info.rect_position.y
	match mode:
		PLAY:
			info.show_how(false)
		TRAIN:
			info.show_notes()
		CHALLENGE:
			info.show_hint()
	if animate:
		info.play_anim()
		animate = false
	info.popup()
	$VBox/Control2/Info.disabled = true
