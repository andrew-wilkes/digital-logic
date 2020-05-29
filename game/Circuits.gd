extends Control

var items = []
var cols = [Color.red, Color.orange, Color.green]

func _ready():
	var list = $VBox/Panel2/ButtonList
	for id in tt.data.keys():
		var item = tt.data[id]
		list.add_item(item.title, cols[0])
		items.append(id)
	list.add_item("Your circuits")


func _on_ButtonList_item_selected(index):
	if index < items.size():
		g.param = items[index] # Store the ID of selected circuit
	return get_tree().change_scene("res://Logic.tscn")
