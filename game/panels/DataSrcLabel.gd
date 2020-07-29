extends Label

signal clicked(line_number)
signal value_changed(id, value)

var id = 0
var line_number = 0
var value = 0
var editable = true
var text_color
var testing = false

func _ready():
	if get_parent().name == "root":
		modulate = Color.black
		testing = true


func set_as_number_field(num = true):
	editable = num


func _on_LabelDialog_updated(new_text):
	if new_text.is_valid_integer():
		value = int(new_text)
		if value > 255:
			value = 255
		if value < -128:
			value = -128
		if value < 0:
			value = 256 + value 
		if testing:
			set_value(value)
		emit_signal("value_changed", id, value)
	else:
		$InvalidNumber.popup_centered()


func set_value(v, txt = ""):
	text = "%02X %s" % [v, txt]
	value = v


func _on_DataSrcLabel_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if editable:
			$Edit.set_text(String(value))
			$Edit.popup_centered()
		else:
			modulate = text_color
			emit_signal("clicked", line_number)


func _on_DataSrcLabel_mouse_entered():
	text_color = modulate
	modulate = g.COLOR_ACTIVE


func _on_DataSrcLabel_mouse_exited():
	modulate = text_color
