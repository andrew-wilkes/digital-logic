extends Part

enum { D, E }
enum { Q1, Q2}

func _ready():
	labels =  ["D","E","+Q","-Q"]


func update_output(_pin, _state):
	# Return if not enabled
	if inputs[E] == false:
		return
	if inputs[D] == outputs[Q2]:
		outputs[Q1] = inputs[D]
		outputs[Q2] = !inputs[D]
		for n in 2:
			emit_signal("state_changed", self, n, outputs[n])
