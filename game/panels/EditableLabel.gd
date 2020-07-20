extends ToolButton
tool

signal updated(txt)

export var default_text = "?"

func _ready():
	print($c/LabelDialog.rect_size)


func _on_Label_button_down():
	$c/LabelDialog.window_title = "Enter label text"
	$c/LabelDialog.set_text(text)
	$c/LabelDialog.popup_centered(Vector2(270, 50))
	print($c/LabelDialog.rect_size)


func _on_LabelDialog_updated(txt):
	update_title(txt)
	emit_signal("updated", txt)


func update_title(txt):
	if txt.empty():
		txt = default_text
	text = txt


func show_label():
	if get_parent().name == "Parts":
		$Label.show()
