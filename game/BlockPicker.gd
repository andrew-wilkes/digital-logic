extends WindowDialog

signal item_selected(item)

var items = []

func _ready():
	var list = $SC/ButtonList
	var files = g.get_files("parts/blocks", "tscn")
	for file in files:
		var node = load("res://parts/blocks/" + file).instance()
		items.append(node)
		list.add_item(node.name)


func _on_ButtonList_item_selected(index):
	var item = items[index].duplicate()
	item.position = rect_position
	emit_signal("item_selected", item)
	hide()
