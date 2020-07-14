extends Part

func _ready():
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	$Outputs/Q.is_output = true
	$Outputs/Q.hide_it()
	connect("dropped", self, "show_label")
	$Label.hide()


func get_labels():
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
