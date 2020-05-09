extends WindowDialog

signal confirmed(title, fn)

func _ready():
	# warning-ignore:return_value_discarded
	$M/Grid/OK.connect("button_down", self, "confirm")
	if get_parent().name == "root":
		show()


func confirm():
	var title = $M/Grid/Title.text.strip_edges()
	if title.empty():
		title = "Item"
	var fn = $M/Grid/Filename.text
	emit_signal("confirmed", title, fn)
	self.hide()


func _on_NameDialog_about_to_show():
	$M/Grid/Title.text = ""
	$M/Grid/Filename.text = ""
