extends Control

var testing = false
var locs
var src = ""

func _ready():
	locs = $VBox/SC/LOCS # Memory location info (hex value + if there is: line of code)
	var loc_line = locs.get_child(0)
	var new_line
	for n in 256:
		if n == 0:
			new_line = loc_line 
		else:
			new_line = loc_line.duplicate()
			locs.add_child(new_line)
		new_line.get_node("ADDR").text = "%02X" % n
		new_line.get_node("SRC").id = n
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

