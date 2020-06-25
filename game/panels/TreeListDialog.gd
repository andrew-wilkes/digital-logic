extends WindowDialog

signal item_selected(id)

func open(cats, items, save_id):
	$TreeList.populate(cats, items, save_id)
	show()


func _on_TreeList_tree_item_selected(_id):
	hide()
	call_deferred("item_selected", _id)


func item_selected(_id):
	emit_signal("item_selected", _id)
