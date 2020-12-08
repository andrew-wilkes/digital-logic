tool
extends GridInput

class_name Grid_Output

var inputs = {}

func set_result(v: bool):
	$Label.self_modulate = g.COLOR_RIGHT if v else g.COLOR_WRONG
