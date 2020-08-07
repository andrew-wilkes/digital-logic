extends HBoxContainer

signal page_changed

func _ready():
	set_max_page()


func set_max_page():
	$Page.max_value = g.max_page


func _on_Page_value_changed(value):
	g.page = int(value)
	emit_signal("page_changed")
