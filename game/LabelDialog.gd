extends WindowDialog

signal updated(txt)

func _on_Button_button_down():
	var txt = $M/HBox/LineEdit.text.strip_edges()
	emit_signal("updated", txt)
	hide()
