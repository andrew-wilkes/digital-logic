extends Part

func _ready():
	allow_testing()
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	connect_signals()
	connect_pin($Outputs/Q)
	$Outputs/Q.is_output = true
	$Outputs/Q.hide_it()
	connect("dropped", self, "show_label")
	$Label.hide()


func get_label():
	return $Label.text


func set_label(txt):
	$Label.text = txt


func _on_Label_button_down():
	$c/LabelDialog.window_title = "Enter label text"
	$c/LabelDialog.set_text(get_label())
	$c/LabelDialog.popup_centered()


func _on_LabelDialog_updated(txt):
	if txt.empty():
		txt = "?"
	set_label(txt)


func show_label():
	if get_parent().name != "Panel":
		$Label.show()
