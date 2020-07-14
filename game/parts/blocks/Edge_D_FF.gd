extends Part

enum { D, CLK }
enum { QP, QN}

var pin_id

func _ready():
	labels =  ["D","CLK","+Q","-Q"]


func update_output(pin, state):
	if outputs[QP]:
		if pin.id == CLK and state and inputs[D] == false:
			set_outputs(false)
	else:
		if pin.id == CLK and state and inputs[D] == true:
			set_outputs(true)

func set_outputs(v):
	outputs[QP] = v
	outputs[QN] = !v
	for n in 2:
		emit_signal("state_changed", self, n, outputs[n])
