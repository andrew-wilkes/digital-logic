extends Control

var items = []

func _ready():
	g.load_circuits()
	var list = find_node("TreeList")
	list.populate(tt.categories, tt.data)
	#list.add_item("Your circuits")


func _on_TreeList_tree_item_selected(id):
	g.param = id # Store the ID of selected circuit
	return get_tree().change_scene("res://Logic.tscn")
