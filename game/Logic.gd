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
		"library":
			choose_circuit()
		"help":
			show_help()


func save_circuit():
	$VBox/Circuit.request_to_save_scene()


func load_circuit():
	$VBox/Circuit.request_to_load_scene()


func choose_circuit():
	$VBox/Circuit.request_to_choose_circuit()


func show_help():
	$c/Help.popup_centered()

