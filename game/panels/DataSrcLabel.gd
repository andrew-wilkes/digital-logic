extends Label

signal clicked(line_number)
signal value_changed(id, value)

var line_number = 0
var id = 0
var value = 0
var editable = true

func _ready():
	if get_parent().name == "root":
		modulate = Color.black


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
			value = 256 - value 
		text = "%02X" % value
		emit_signal("value_changed", id, value)
	else:
		$InvalidNumber.popup_centered()


func _on_DataSrcLabel_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if editable:
			$Edit.set_text(String(value))
			$Edit.popup_centered()
		else:
			emit_signal("clicked", line_number)
