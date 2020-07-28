extends WindowDialog

var testing = false

func _ready():
	$Tabs.set_tab_title(0, "Memory Viewer")
	if get_parent().name == "root":
		testing = true
		open([])

func open(data: Array, title = ""):
	g.mem = data
	if title != "":
		window_title += " - " + title
	call_deferred("popup_centered")
	$Tabs/MemoryViewer.start(testing)
