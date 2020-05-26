extends MarginContainer

onready var circuit = $VBox/HBox2/Circuit

func _ready():
	var menu = find_node("Menu")
	menu.connect("button_pressed", self, "process_buttons")
	$VBox/HBox2/PartsPicker.connect("picked", circuit, "part_picked")
	$c/AccessoryPicker.connect("item_selected", self, "add_accessory_to_circuit")


func process_buttons(action):
	match action:
		"load":
			load_circuit()
		"save":
			save_circuit()
		"library":
			choose_circuit()
		"info":
			show_help()


func save_circuit():
	circuit.request_to_save_scene()


func load_circuit():
	circuit.request_to_load_scene()


func choose_circuit():
	circuit.request_to_choose_circuit()


func show_help():
	$c/Help.popup_centered()


func _on_Circuit_details_changed(c):
	find_node("Subtitle").text = c.title
	find_node("Description").text = c.desc


func _on_Access_button_down():
	$c/AccessoryPicker.popup_centered()


func add_accessory_to_circuit(item):
	circuit.part_picked(item)


func _on_Hint_button_down():
	pass # Replace with function body.


func _on_Truth_button_down():
	pass # Replace with function body.
