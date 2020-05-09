extends WindowDialog

signal item_selected(cid)

var items = []
var item_to_delete

func _ready():
	if get_parent().name == "root":
		show()
	set_items()


func set_items():
	items = [{
		"title": "New Circuit",
		"cid": "",
	}]
	for cid in g.circuits.keys():
		items.append({
			"title": g.circuits[cid].title,
			"cid": cid
		})
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
		emit_signal("item_selected", items[_index].cid)
		self.hide()


func _on_Confirm_confirmed():
	var cid = items[item_to_delete].cid
	g.circuits.erase(cid)
	g.delete_file(g.PART_FILE_PATH, cid + ".tscn")
	set_items()
