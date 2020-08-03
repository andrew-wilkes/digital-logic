extends Control

signal clicked(line_number)
signal value_changed(id, value)

var id = 0
var line_number = 0
var value = 0
var editable = true
var text_color = [0, 0, 0]
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


func set_value(v):
	$Labels/Value.text = "%02X" % v
	value = v


func set_values(v, label = "", src = ""):
	set_value(v)
	$Labels/Label.text = label
	$Labels/SRC.text = src


func _on_DataSrcLabel_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if editable:
			$Edit.set_text(String(value))
			$Edit.popup_centered()
		else:
			restore_colors()
			emit_signal("clicked", line_number)


func _on_DataSrcLabel_mouse_entered():
	text_color = [$Labels/Value.modulate, $Labels/Label.modulate, $Labels/SRC.modulate]
	for n in $Labels.get_children():
		n.modulate = g.COLOR_ACTIVE


func _on_DataSrcLabel_mouse_exited():
	restore_colors()


func restore_colors():
	$Labels/Value.modulate = text_color[0]
	$Labels/Label.modulate = text_color[1]
	$Labels/SRC.modulate = text_color[2]
