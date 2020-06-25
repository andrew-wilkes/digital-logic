extends MarginContainer

onready var circuit = $VBox/HBox2/Circuit

var cid
var hint_button
var truth_button
var hp
var np
var button

func _ready():
	var menu = find_node("Menu")
	button = find_node("Circuits")
	button_change_state(true)
	button.connect("mouse_entered", self, "button_change_state", [false])
	button.connect("mouse_exited", self, "button_change_state", [true])
	menu.connect("button_pressed", self, "process_buttons")
	$VBox/HBox2/PartsPicker.connect("picked", circuit, "part_picked")
	$c/AccessoryPicker.connect("item_selected", self, "add_item_to_circuit")
	$c/BlockPicker.connect("item_selected", self, "add_item_to_circuit")
	hint_button = find_node("Hint")
	truth_button = find_node("Truth")
	hp = $c/HintPanel
	np = $c/NotificationPopup
	hint_button.visible = false
	truth_button.visible = false
	# This is done here rather than in cicuits scene because details changed signal from save_scene() affects hint_button
	g.load_circuits()
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
				"id": circuit.idx,
				"status": 0
			}
			circuit.save_scene()


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
	if circuit.request_to_save_scene():
		np.notify("Saved")


func load_circuit():
	if circuit.request_to_load_scene():
		np.notify("Reloaded")


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


func add_item_to_circuit(item):
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


func _on_Block_button_down():
	$c/BlockPicker.popup_centered()


func _on_Edit_button_down():
	circuit.edit_details()


func _on_Delete_button_down():
	circuit.request_delete_circuit()
