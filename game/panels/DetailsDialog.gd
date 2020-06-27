extends WindowDialog

signal updated(title, description)

func open(title = "", description = ""):
	find_node("Title").text = title
	find_node("Description").text = description
	popup_centered()


func _on_Button_button_down():
	var title = find_node("Title").text.strip_edges()
	if title.empty():
		title = "Untitled"
	var description = find_node("Description").text.strip_edges()
	emit_signal("updated", title, description)
	hide()


func _on_Title_text_entered(_new_text):
	_on_Button_button_down()
