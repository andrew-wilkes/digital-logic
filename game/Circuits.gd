extends Control

var items = []

func _ready():
	var list = $VBox/Panel2/ButtonList
	for id in tt.data.keys():
		list.add_item(tt.data[id].title)
		items.append(id)
	list.add_item("New blank circuit")


func _on_ButtonList_item_selected(index):
	if index < items.size():
		g.param = items[index]
	return get_tree().change_scene("res://Logic.tscn")
