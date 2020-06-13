extends Container

signal item_selected(index)
signal rmb_click(index)

var color
var item_count = 0
onready var list = $VBox
var unconnected = true

func add_item(txt, mod = Color.gray):
	var item : Node = list.get_child(0)
	if item_count > 0:
		item = item.duplicate()
	item.get_child(0).get_child(0).text = txt
	item.self_modulate = mod
	item.get_child(0).rect_size.x = rect_size.x
	if item_count > 0 or unconnected:
		item.connect("mouse_entered", self, "mouse_in", [item])
		item.connect("mouse_exited", self, "mouse_out", [item])
		item.get_child(0).connect("button_down", self, "clicked", [item_count])
		item.get_child(0).connect("gui_input", self, "gui_input", [item_count])
		unconnected = false
	if item_count > 0:
		list.add_child(item)
	item_count += 1


func clear():
	for i in range(1, item_count):
		list.get_child(i).queue_free()
	item_count = 0


func clicked(i):
	emit_signal("item_selected", i)


func mouse_in(item):
	color = item.self_modulate
	item.self_modulate = color.lightened(0.5)


func mouse_out(item):
	item.self_modulate = color


func gui_input(event, i):
	if event is InputEventMouseButton:
		if !event.pressed && event.button_index == 2:
			emit_signal("rmb_click", i)
