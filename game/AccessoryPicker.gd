extends WindowDialog

signal item_selected(item)

var items = []
var pos

func _ready():
	if get_parent().name == "root":
		show()
	var files = g.get_files("parts/accessories", "tscn")
	for file in files:
		var node = load("res://parts/accessories/" + file).instance()
		items.append(node)
		$M/ItemList.add_item(String(file).replace("_", " "))


func _on_ItemList_item_selected(index):
	var item = items[index].duplicate()
	if pos:
		item.position = pos
	emit_signal("item_selected", item)
	hide()


func _on_ItemList_gui_input(event):
	pos = event.position
