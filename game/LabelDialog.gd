extends WindowDialog

signal updated(txt)

func _on_Button_button_down():
	var txt = $M/HBox/TextEdit.text
	if txt == "":
		txt = "?"
	emit_signal("updated", txt)
	hide()
