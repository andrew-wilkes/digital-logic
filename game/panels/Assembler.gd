extends Control

signal compile
signal saved

var src_file_name = ""

func _ready():
	$FileDialog.set_current_dir(g.SRC_FILE_PATH)
	$FileDialog.set_current_path(g.SRC_FILE_PATH)
	$FileDialog.set_filters(PoolStringArray(["*.asq ; SUBLEQ Source Code"]))


func set_src(title: String):
	if title.empty():
		title = "Program"
	src_file_name = title
	$FileDialog.set_current_file(src_file_name)
	$VBox/SRC.text = g.src


func _on_CompileButton_button_down():
	update_src()
	emit_signal("compile")


func update_src():
	g.src = $VBox/SRC.text.strip_edges()


func show_msg(m, line_num):
	highlight_line(line_num)
	$Alert.dialog_text = m
	$Alert.popup_centered()


func highlight_line(line_num):
	$VBox/SRC.cursor_set_line(line_num - 1)


func _on_Save_button_down():
	$FileDialog.mode = FileDialog.MODE_SAVE_FILE
	$FileDialog.popup_centered(g.popup_size)


func _on_Load_button_down():
	$FileDialog.mode = FileDialog.MODE_OPEN_FILE
	$FileDialog.popup_centered(g.popup_size)


func _on_FileDialog_confirmed():
	var path = $FileDialog.get_current_path()
	var fn = $FileDialog.get_current_file()
	if $FileDialog.mode == FileDialog.MODE_SAVE_FILE:
		if fn.is_valid_filename():
			if fn.get_extension().empty():
				path += ".asq"
			update_src()
			g.save_file(path, g.src, false)
			emit_signal("saved")
		else:
			$Alert.dialog_text = "Invalid file name"
			$Alert.popup_centered()
	else:
		g.src = g.load_file(path, false)
		set_src(fn)
