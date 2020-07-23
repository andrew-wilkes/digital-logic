extends Part

var count = 0
var triggered = false

enum { CLK, RST }
const CO = 10

func _ready():
	outputs[CO] = true
	outputs[0] = true


func update_output(_pin, _state):
	if _pin.id == CLK and _state and !inputs[RST]:
		set_output(count, false)
		count += 1
		if count > 9:
			count = 0
			set_output(CO, true)
		set_output(count, true)
		if count == 5:
			set_output(CO, false)
	if _pin.id == RST:
		# Delay reset detection
		if !triggered:
			triggered = true
			$Timer.start()


func set_output(_idx, _v):
	set_output_state($Outputs.get_child(_idx), _v)


func set_output_state(_pin, _state):
	outputs[_pin.id] = _state
	emit_signal("state_changed", self, _pin.id, _state)


func _on_Timer_timeout():
	triggered = false
	if inputs[RST]:
		if count > 0:
			set_output(count, false)
			count = 0
			set_output(count, true)
		if outputs[CO] == false:
			set_output(CO, true)
