extends WindowDialog

signal updated(txt)

func set_text(txt):
	if txt == "?":
		txt = ""
	$M/HBox/LineEdit.text = txt


func _on_Button_button_down():
	var txt = $M/HBox/LineEdit.text.strip_edges()
	emit_signal("updated", txt)
	hide()
