extends ToolButton
tool

export var default_text = "?" setget _on_LabelDialog_updated

func _on_Label_button_down():
	$c/LabelDialog.window_title = "Enter label text"
	$c/LabelDialog.set_text(text)
	$c/LabelDialog.popup_centered()


func _on_LabelDialog_updated(txt):
	if txt.empty():
		txt = default_text
	text = txt


func show_label():
	if get_parent().name == "Parts":
		$Label.show()
