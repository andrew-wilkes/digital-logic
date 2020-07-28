extends WindowDialog

signal updated(txt)

func _ready():
	if get_parent().name == "root":
		call_deferred("popup_centered")


func set_text(txt):
	if txt == "?":
		txt = ""
	$M/HBox/LineEdit.text = txt


func _on_Button_button_down():
	done()


func _on_LineEdit_text_entered(_new_text):
	done()


func done():
	var txt = $M/HBox/LineEdit.text.strip_edges()
	emit_signal("updated", txt)
	hide()
