extends WindowDialog

signal item_selected(file_name)

var items = []
var item_to_delete

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
	# This is triggered by any mouse button click
	item_to_delete = null
	call_deferred("item_selected", index)


func _on_FileDialog_about_to_show():
	set_items()


func _on_Items_item_rmb_selected(index, _at_position):
	if index > 0: # Ignore New Circuit option
		item_to_delete = index
	


func item_selected(_index):
	if item_to_delete:
		$Confirm.popup_centered()
	else:
		emit_signal("item_selected", items[_index].file_name)
		self.hide()


func _on_Confirm_confirmed():
	g.delete_file(g.PART_FILE_PATH, items[item_to_delete].file_name + ".json")
	g.delete_file(g.PART_FILE_PATH, items[item_to_delete].file_name + ".tscn")
	set_items()
