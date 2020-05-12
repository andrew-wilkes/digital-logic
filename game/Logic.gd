extends MarginContainer

onready var circuit = $VBox/HBox2/Circuit

func _ready():
	var menu = find_node("Menu")
	menu.connect("button_pressed", self, "process_buttons")
	# warning-ignore:return_value_discarded
	$VBox/HBox2/PartsPicker.connect("picked", circuit, "part_picked")


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
	circuit.request_to_save_scene()


func load_circuit():
	circuit.request_to_load_scene()


func choose_circuit():
	circuit.request_to_choose_circuit()


func show_help():
	$c/Help.popup_centered()


func _on_Circuit_title_changed(title):
	find_node("Subtitle").text = title
