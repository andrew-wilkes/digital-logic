extends WindowDialog

var testing = false

func _ready():
	$Tabs.set_tab_title(0, "Memory Viewer")
	if get_parent().name == "root":
		testing = true
		open()


func open(title = ""):
	if title != "":
		window_title += " - " + title
	g.max_page = int(g.mem.size() / 256) - 1
	call_deferred("popup_centered", Vector2(790, 430))
	$Tabs/MemoryViewer.start(testing)
	$Tabs/Disassembler.load_memory()
	$Tabs/Assembler.set_src(title)


func _on_Assembler_compile():
	$Tabs.set_current_tab(1)
	$Tabs/Disassembler.compile()


func _on_Disassembler_code_error(msg, line_num):
	$Tabs.set_current_tab(2)
	$Tabs/Assembler.show_msg(msg, line_num)


func _on_Disassembler_edit_source(line_num):
	$Tabs.set_current_tab(2)
	$Tabs/Assembler.highlight_line(line_num)
