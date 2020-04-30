extends HBoxContainer

signal button_pressed(action)

func _on_Load_button_down():
	emit_signal("button_pressed", "load")


func _on_Save_button_down():
	emit_signal("button_pressed", "save")


func _on_Play_button_down():
	emit_signal("button_pressed", "play")


func _on_Library_button_down():
	emit_signal("button_pressed", "library")


func _on_Help_button_down():
	emit_signal("button_pressed", "help")
