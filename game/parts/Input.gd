extends Part

var labels = [] setget set_labels, get_label

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


func get_label():
	return [$Label.text]


func set_labels(arr):
	if arr.empty():
		$Label.text = "?"
	else:
		set_label(arr[0])


func set_label(txt):
	if txt.empty():
		txt = "?"
	$Label.text = txt
	labels = [txt]


func show_label():
	if get_parent().name == "Parts":
		$Label.show()


# Used when testing
func set_state(value, _idx):
	change_input_state(value)
