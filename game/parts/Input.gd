extends Part


func _ready():
	allow_testing()
	v_spacing = 56
	color = g.COLOR_UNDEFINED
	modulate = color
	connect_signals()
	connect_pin($Q)
	$Q.is_output = true
	pin_exit($Q) # Hide


func _on_Label_button_down():
	$LabelDialog.popup_centered()


func _on_LabelDialog_updated(txt):
	$Label.text = txt
	$Label.FOCUS_NONE
