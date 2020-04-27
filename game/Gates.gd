extends Control

func _ready():
	for part in $VBox/ColorRect.get_children():
		part.connect("picked", self, "clicked")


func clicked(part):
	print(part)
	"""
	part.state = !part.state
	part.indicate_state()
	return
	if part.is_ext_input:
		gate.state = !gate.state
	"""
