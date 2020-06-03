extends Part

var labels = [] setget ,get_labels

func _ready():
	allow_testing()
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	connect_signals()
	connect_pin($Outputs/Q)
	$Outputs/Q.is_output = true
	outputs = [false]
	$Outputs/Q.hide_it()
	connect("dropped", self, "show_label")
	$Label.hide()


func get_labels():
	return [$Label.text]


func set_label(txt):
	$Label.text = txt
	labels.append(txt)


func show_label():
	if get_parent().name == "Parts":
		$Label.show()


# Used when testing
func set_state(value, _idx):
	change_input_state(value)
