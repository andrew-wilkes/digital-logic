extends MarginContainer

func _ready():
	var menu = find_node("Menu")
	menu.connect("button_pressed", self, "process_buttons")


func process_buttons(action):
	match action:
		"load":
			load_circuit()
		"save":
			save_circuit()


func save_circuit():
	$VBox/Circuit.save_scene("Test", "test")


func load_circuit():
	$VBox/Circuit.load_scene("test")
