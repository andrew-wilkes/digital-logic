extends Control

var items = []

func _ready():
	var list = $VBox/ItemList
	for id in tt.data.keys():
		list.add_item(tt.data[id].title)
		items.append(id)


func _on_ItemList_item_selected(index):
	g.param = items[index]
	return get_tree().change_scene("res://Logic.tscn")
