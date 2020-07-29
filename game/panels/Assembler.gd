extends Control

signal compile

func load_src():
	$VBox/SRC.text = g.src


func _on_CompileButton_button_down():
	g.src = $VBox/SRC.text.strip_edges()
	emit_signal("compile")


func show_msg(m, line_num):
	highlight_line(line_num)
	$Alert.dialog_text = m
	$Alert.popup_centered()


func highlight_line(line_num):
	$VBox/SRC.cursor_set_line(line_num)
