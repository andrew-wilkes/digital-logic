tool
extends GridInput

class_name Grid_Output

var inputs = {}
var state = false

func set_result(v: bool):
	$Label.self_modulate = g.COLOR_RIGHT if v else g.COLOR_WRONG
