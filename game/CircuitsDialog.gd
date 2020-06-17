extends WindowDialog

signal item_selected(cid)
signal item_deleted

var items = []
var item_to_delete
var num_funcs = 0

func _ready():
	if get_parent().name == "root":
		set_items()


func set_items(editable = true):
	num_funcs = 1
	items = [{
		"title": "New Circuit",
		"cid": "new",
		"status": 0
	}]
	if editable:
		num_funcs = 2
		items.append({
			"title": "Rename Circuit",
			"cid": "rename",
			"status": 0
		})
	for cid in g.circuits.keys():
		items.append({
			"title": g.circuits[cid].title,
			"cid": cid,
			"status": g.circuits[cid].status
		})
	$SC/ButtonList.clear()
	for i in items:
		$SC/ButtonList.add_item(i.title, g.STATUS_COLORS[i.status])
	popup_centered()


func _on_ButtonList_item_selected(index):
	item_to_delete = null
	call_deferred("item_selected", index)


func _on_ButtonList_rmb_click(index):
	if index >= num_funcs: # Ignore functional options
		item_to_delete = index
		$Confirm.popup_centered()


func item_selected(_index):
	emit_signal("item_selected", items[_index].cid)
	self.hide()


func _on_Confirm_confirmed():
	var cid = items[item_to_delete].cid
	g.circuits.erase(cid)
	g.save_file(g.PART_FILE_PATH + "data.json", g.circuits)
	g.delete_file(g.PART_FILE_PATH, cid + ".tscn")
	set_items()
	emit_signal("item_deleted")