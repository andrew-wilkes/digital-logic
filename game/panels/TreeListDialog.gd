extends WindowDialog

signal item_selected(id)

func _ready():
	if get_parent().name == "root":
		g.load_circuits()
		list_circuits()
		show()


func list_circuits():
	var cats = tt.categories.duplicate(true)
	cats["Custom"] = { "Uncategorized": "unc" }
	var data_keys = tt.data.keys()
	var circuits = tt.data.duplicate()
	for c_key in g.circuits.keys():
		if !data_keys.has(c_key):
			circuits[c_key] = {
				title = g.circuits[c_key].title,
				cat = "unc"
			}
	$TreeList.populate(cats, circuits, 1)


func _on_TreeList_tree_item_selected(_id):
	hide()
	call_deferred("item_selected", _id)


func item_selected(_id):
	emit_signal("item_selected", _id)
