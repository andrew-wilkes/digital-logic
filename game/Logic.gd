extends MarginContainer

onready var circuit = $VBox/HBox2/Circuit

var cid
var hint_button
var truth_button
var hp

func _ready():
	var menu = find_node("Menu")
	menu.connect("button_pressed", self, "process_buttons")
	$VBox/HBox2/PartsPicker.connect("picked", circuit, "part_picked")
	$c/AccessoryPicker.connect("item_selected", self, "add_accessory_to_circuit")
	hint_button = find_node("Hint")
	truth_button = find_node("Truth")
	hp = $c/HintPanel
	hint_button.visible = false
	truth_button.visible = false


func process_buttons(action):
	match action:
		"load":
			load_circuit()
		"save":
			save_circuit()
		"play":
			if truth_button.visible:
				test_circuit(true)
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
	cid = c.id
	if tt.data.keys().has(cid):
		c.title = tt.data[cid].title
		c.desc = tt.data[cid].desc
		hint_button.visible = true
		truth_button.visible = true
	else:
		hint_button.visible = false
		truth_button.visible = false
	find_node("Subtitle").text = c.title
	find_node("Description").text = c.desc


func _on_Access_button_down():
	$c/AccessoryPicker.popup_centered()


func add_accessory_to_circuit(item):
	circuit.part_picked(item)


func _on_Hint_button_down():
	hp.text = tt.data[cid].hint


func _on_Truth_button_down():
	$c/TruthPanel/TruthTable.populate(tt.data[cid])
	$c/TruthPanel.rect_size = Vector2(100, 100)
	$c/TruthPanel.popup_centered()


func _on_TruthPanel_popup_hide():
	$c/TruthPanel/TruthTable.clear()


func _on_TruthPanel_test_button_down():
	print("test_button_pressed")
	test_circuit(false)


func test_circuit(open_tt):
	if open_tt:
		_on_Truth_button_down()
