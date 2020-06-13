extends Part

enum { STOPPED, PULSING, OSCILLATING }

const rates = [0, 2, 4, 8, 15, 30, 60, 120, 240]

var labels =  []
var count = 0
var delay = 0
var clk_state = STOPPED
var start = false
var fire = false
var reset = false
var timer_stopped = true
var rate

func _ready():
	allow_testing()
	z_index = 1 # Display above wires
	connect_signals()
	var i = 0
	for node in $Outputs.get_children():
		node.id = i
		node.is_output = true
		connect_pin(node)
		i += 1
	outputs = [true, false] # cause outputs to flip
	call_deferred("reset_output")
	set_rate()


func _process(_delta):
	match clk_state:
		STOPPED:
			if reset:
				reset = false
				reset_output()
			if start:
				start = false
				$Start.text = "STOP"
				start_oscillating()
				$Fire.disabled = true
				clk_state = OSCILLATING
			if fire:
				fire = false
				$Start.disabled = true
				$Fire.disabled = true
				start_pulsing()
				clk_state = PULSING
		OSCILLATING:
			if reset or start:
				start = false
				$Start.text = "START"
				$Fire.disabled = false
				clk_state = STOPPED
				return
			if timer_stopped:
				timer_stopped = false
				flip_outputs()
				start_oscillating()
		PULSING:
			if reset:
				$Start.disabled = false
				$Fire.disabled = false
				clk_state = STOPPED
				return
			if timer_stopped:
				timer_stopped = false
				flip_outputs()
				count -= 1
				if count == 0:
					$Start.disabled = false
					$Fire.disabled = false
					clk_state = STOPPED
				else:
					start_oscillating()


func flip_outputs():
	update_output(!outputs[0], 0)
	update_output(!outputs[1], 1)
	set_led()


func update_output(value, idx):
	outputs[idx] = value
	emit_signal("new_event")
	emit_signal("state_changed", self, idx, value)


func start_pulsing():
	count = pow(2, $VSlider.value)
	start_oscillating()


func start_oscillating(): 
	delay = 1.0 / rate
	$Timer.wait_time = delay
	$Timer.start()
	timer_stopped = false


func _on_Start_button_down():
	start = true


func _on_Fire_button_down():
	fire = true


func _on_Reset_button_down():
	reset = true


func reset_output():
	if outputs[0]:
		flip_outputs()
	emit_signal("new_event")
	emit_signal("state_changed", self, 2, true)
	set_led()


func _on_Timer_timeout():
	timer_stopped = true


func _on_VSlider_value_changed(_value):
	set_rate()


func set_led():
	$LED.modulate = g.get_state_color(outputs[0])


func set_rate():
	rate = rates[int($VSlider.value)]
	print(rate)
