extends WindowDialog

signal updated(title, description)

func set_text(title, description):
	$M/VBox/Title.text = title
	$M/VBox/Description.txt = description


func _on_Button_button_down():
	var title = $M/VBox/Title.text.strip_edges()
	if title.empty():
		title = "Untitled"
	var description = $M/VBox/Description.text.strip_edges()
	emit_signal("updated", title, description)
	hide()
