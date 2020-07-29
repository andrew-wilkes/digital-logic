extends WindowDialog

var testing = false

func _ready():
	$Tabs.set_tab_title(0, "Memory Viewer")
	if get_parent().name == "root":
		testing = true
		open([])

func open(data: Array, src = "", title = ""):
	g.mem = data
	g.src = src
	if title != "":
		window_title += " - " + title
	call_deferred("popup_centered")
	$Tabs/MemoryViewer.start(testing)
