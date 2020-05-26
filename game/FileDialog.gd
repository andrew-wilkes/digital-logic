extends WindowDialog

signal item_selected(cid)
signal item_deleted

var items = []
var item_to_delete

func _ready():
	if get_parent().name == "root":
		set_items()


func set_items(editable = true):
	items = [{
		"title": "New Circuit",
		"cid": "new",
	}]
	if editable:
		items.append({
			"title": "Rename Circuit",
			"cid": "rename",
		})
	for cid in g.circuits.keys():
		items.append({
			"title": g.circuits[cid].title,
			"cid": cid
		})
	$M/Items.clear()
	for i in items:
		$M/Items.add_item(i.title)
	popup_centered()


func _on_Items_item_selected(index):
	# This is triggered by any mouse button click
	item_to_delete = null
	call_deferred("item_selected", index)


func _on_Items_item_rmb_selected(index, _at_position):
	if index > 1: # Ignore functional options
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
	g.save_file(g.PART_FILE_PATH + "data.json", g.circuits)
	g.delete_file(g.PART_FILE_PATH, cid + ".tscn")
	set_items()
	emit_signal("item_deleted")
