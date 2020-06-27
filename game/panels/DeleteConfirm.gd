extends ConfirmationDialog

signal item_deleted

var cid

func open(_id):
	cid = _id
	popup_centered()


func _on_DeleteConfirm_confirmed():
	g.circuits.erase(cid)
	g.save_file(g.PART_FILE_PATH + "data.json", g.circuits)
	g.delete_file(g.PART_FILE_PATH, cid + ".tscn")
	emit_signal("item_deleted")
