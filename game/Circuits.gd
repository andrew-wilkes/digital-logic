extends Control

var items = []

func _ready():
	g.load_circuits()
	var list = $VBox/Panel2/ButtonList
	for id in tt.data.keys():
		var item = tt.data[id]
		var status = 0
		if g.circuits.keys().has(id):
			status = g.circuits[id].status
		list.add_item(item.title, g.STATUS_COLORS[status])
		items.append(id)
	list.add_item("Your circuits")


func _on_ButtonList_item_selected(index):
	if index < items.size():
		g.param = items[index] # Store the ID of selected circuit
	return get_tree().change_scene("res://Logic.tscn")
