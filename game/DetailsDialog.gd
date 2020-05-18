extends WindowDialog

signal updated(title, description)

func set_text(title, description):
	find_node("Title").text = title
	find_node("Description").txt = description


func _on_Button_button_down():
	var title = find_node("Title").text.strip_edges()
	if title.empty():
		title = "Untitled"
	var description = find_node("Description").text.strip_edges()
	emit_signal("updated", title, description)
	hide()
