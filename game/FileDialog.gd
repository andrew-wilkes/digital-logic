extends WindowDialog

signal item_selected(file_name)

var items = []

func _ready():
	if get_parent().name == "root":
			show()
	set_items()


func set_items():
	items = [{
		"title": "New Circuit",
		"file_name": "",
	}]
	var files = g.get_files(g.PART_FILE_PATH, "json")
	for fn in files:
		var circuit = g.load_file(g.PART_FILE_PATH + fn)
		items.append(circuit)
	$M/Items.clear()
	for i in items:
		$M/Items.add_item(i.title)


func _on_Items_item_selected(index):
	emit_signal("item_selected", items[index].file_name)
	self.hide()


func _on_FileDialog_about_to_show():
	set_items()
