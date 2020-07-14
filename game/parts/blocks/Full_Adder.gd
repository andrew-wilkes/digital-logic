extends Part

enum { A, B, Cin }
enum { Sum, Cout }

func _ready():
	labels =  ["A", "B", "Cin", "Sum", "Cout"]


func update_output(_pin, _state):
	var sum = int(inputs[A]) + int(inputs[B]) + int(inputs[Cin])
	outputs[Sum] = bool(sum % 2)
	outputs[Cout] = sum > 1
	for n in 2:
		emit_signal("state_changed", self, n, outputs[n])
