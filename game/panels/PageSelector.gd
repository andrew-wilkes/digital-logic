extends HBoxContainer

signal page_changed

func _ready():
	$Page.max_value = g.max_page


func _on_Page_value_changed(value):
	g.page = int(value)
	emit_signal("page_changed")
