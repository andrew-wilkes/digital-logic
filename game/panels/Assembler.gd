extends Control

var testing = false
var lines
var src = ""

func _ready():
	lines = $VBox/SC/V
	var line = lines.get_child(0)
	var new_line
	for n in 256:
		if n == 0:
			new_line = line 
		else:
			new_line = line.duplicate()
			lines.add_child(new_line)
		new_line.get_child(0).text = "%02X" % n
		new_line.get_child(1).set_meta("id", n)
	if get_parent().name == "root":
		start(true)
	else:
		$BG.hide()


func start(_test = false):
	testing = _test
	if testing:
		$BG.show()


func update_addresses():
	for n in 256:
		pass

