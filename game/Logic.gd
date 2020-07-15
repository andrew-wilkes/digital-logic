extends MarginContainer

onready var circuit = $VBox/HBox2/Circuit

var cid
var hint_button
var truth_button
var hp
var np
var button
var accessories = []
var a_names = []
var blocks = []
var b_names = []

func _ready():
	var menu = find_node("Menu")
	button = find_node("Circuits")
	button_change_state(true)
	button.connect("mouse_entered", self, "button_change_state", [false])
	button.connect("mouse_exited", self, "button_change_state", [true])
	menu.connect("button_pressed", self, "process_buttons")
	$VBox/HBox2/PartsPicker.connect("picked", circuit, "part_picked")
	$c/AccessoryPicker.connect("item_selected", self, "accessory_picked")
	$c/BlockPicker.connect("item_selected", self, "block_picked")
	hint_button = find_node("Hint")
	truth_button = find_node("Truth")
	hp = $c/HintPanel
	np = $c/NotificationPopup
	hint_button.visible = false
	truth_button.visible = false
	get_accessories()
	get_blocks()
	# Details changed signal from save_scene() affects hint_button
	if g.param: # It's a tutorial scene
		circuit.idx = g.param
		if g.circuits.keys().has(circuit.idx):
			circuit.load_scene()
		else:
			var d = tt.data[circuit.idx]
			circuit.add_io_parts(d)
			g.circuits[circuit.idx] = {
				"title": d.title,
				"desc": d.desc,
				"offset": { "x": 0, "y": 0 },
				"status": 0
			}
			circuit.call_deferred("save_scene")


func get_accessories():
	var files = g.get_files("res://parts/accessories", "tscn")
	for file in files:
		var node = load("res://parts/accessories/" + file).instance()
		accessories.append(node)
		a_names.append(node.name)


func get_blocks():
	var files = g.get_files("res://parts/blocks", "tscn")
	for file in files:
		var node = load("res://parts/blocks/" + file).instance()
		blocks.append(node)
		b_names.append(node.name)


func button_change_state(disabled):
	button.disabled = disabled


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
	if circuit.request_to_load_scene():
		np.notify("Reloaded")


func choose_circuit():
	circuit.request_to_choose_circuit()


func show_help():
	$c/Help.popup_centered()


func _on_Circuit_details_changed(c, saved):
	cid = circuit.idx
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
	if saved:
		np.notify("Saved")


func _on_Access_button_down():
	$c/AccessoryPicker.open(a_names)


func accessory_picked(index):
	var item = accessories[index].duplicate()
	add_item_to_circuit(item)


func _on_Block_button_down():
	$c/BlockPicker.open(b_names)


func block_picked(index):
	var item = blocks[index].duplicate()
	add_item_to_circuit(item)


func add_item_to_circuit(item):
	item.position = get_viewport().get_mouse_position() - circuit.get_global_rect().position
	circuit.part_picked(item)


func _on_Hint_button_down():
	hp.text = tt.data[cid].hint
	hint_button.disabled = true


func _on_Truth_button_down():
	$c/TruthPanel.open(cid)
	truth_button.disabled = true


func _on_TruthPanel_popup_hide():
	$c/TruthPanel/TruthTable.clear()
	# Clicking on button closes the window so need to block it activating immediately
	truth_button.call_deferred("set_disabled", false)


func _on_TruthPanel_test_button_down():
	print("test_button_pressed")
	test_circuit(false)


func test_circuit(open_tt):
	if open_tt:
		_on_Truth_button_down()
	$c/TruthPanel.test_circuit(circuit)


func _on_HintPanel_popup_hide():
	hint_button.call_deferred("set_disabled", false)


func _on_Edit_button_down():
	circuit.edit_details()


func _on_Delete_button_down():
	circuit.request_delete_circuit()
