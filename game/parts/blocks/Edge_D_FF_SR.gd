extends Part

enum { D, CLK, S, R }
enum { QP, QN}

func _ready():
	labels =  ["D","CLK","+Q","-Q"]


func update_output(pin, state):
	if outputs[QP]:
		if pin.id == S and state == false and inputs[R]:
			set_outputs(false)
		if pin.id == R and state and inputs[S] == false:
			set_outputs(false)
		if pin.id == CLK and state and inputs[S] == false and inputs[D] == false:
			set_outputs(false)
	else:
		if pin.id == S and state:
			set_outputs(true)
		if pin.id == CLK and state and inputs[R] == false and inputs[D] == true:
			set_outputs(true)


func set_outputs(v):
	outputs[QP] = v
	outputs[QN] = !v
	for n in 2:
		emit_signal("state_changed", self, n, outputs[n])
