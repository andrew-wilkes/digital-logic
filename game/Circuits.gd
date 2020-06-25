extends Control

var items = []

func _ready():
	g.load_circuits()
	var list = find_node("TreeList")
	list.populate(tt.categories, tt.data, 0)


func _on_TreeList_tree_item_selected(id):
	g.param = id # Store the ID of selected circuit
	open_editor()


func _on_Button_button_down():
	open_editor()


func open_editor():
	return get_tree().change_scene("res://Logic.tscn")
