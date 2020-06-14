extends Part

signal clock

enum { STOPPED, PULSING, OSCILLATING, RESETTING }

var labels =  []
var count = 0
var delay = 0
var clk_state = STOPPED
var start = false
var fire = false
var reset = false
var timer_stopped = true
var rate
var num_ticks

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
	outputs = [true, false, false] # cause outputs to flip
	call_deferred("reset_output")
	set_rate()


func _process(_delta):
	match clk_state:
		STOPPED:
			if reset:
				reset = false
				reset_output()
				update_output(true, 2)
				run_timer()
				clk_state = RESETTING
			if start:
				start = false
				$Start.text = "STOP"
				run_timer()
				$Fire.disabled = true
				count = 0
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
				count += 1
				if count == num_ticks:
					count = 0
				run_timer()
		PULSING:
			if reset:
				$Start.disabled = false
				$Fire.disabled = false
				clk_state = STOPPED
				return
			if timer_stopped:
				timer_stopped = false
				flip_outputs()
				count += 1
				if count == num_ticks:
					$Start.disabled = false
					$Fire.disabled = false
					clk_state = STOPPED
				else:
					run_timer()
		RESETTING:
			if timer_stopped:
				timer_stopped = false
				update_output(false, 2)
				clk_state = STOPPED


func flip_outputs():
	update_output(!outputs[0], 0)
	update_output(!outputs[1], 1)
	set_led()


func update_output(value, idx):
	outputs[idx] = value
	emit_signal("new_event")
	emit_signal("state_changed", self, idx, value)


func start_pulsing():
	count = 0
	flip_outputs()
	run_timer()


func run_timer(): 
	delay = 0.5 / rate
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
	emit_signal("clock")


func _on_VSlider_value_changed(_value):
	set_rate()


func set_led():
	$LED.modulate = g.get_state_color(outputs[0])


func set_rate():
	rate = pow(2, $VSlider.value)
	num_ticks = rate * 2 - 1
