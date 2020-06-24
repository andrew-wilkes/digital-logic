extends MarginContainer

signal tree_item_selected(id)

var tree : Tree
var item_script

func _ready():
	tree = $Tree
	$Bar.hide()
	populate(tt.categories, tt.data)


func populate(cats, data):
	var root = tree.create_item()
	for cat in cats.keys():
		var b = tree.create_item(root)
		b.set_text(0, cat)
		b.set_collapsed(false)
		for sub_cat in cats[cat].keys():
			var b2 = tree.create_item(b)
			b2.set_text(0, sub_cat)
			b2.set_collapsed(false)
			for key in data.keys():
				var item = data[key]
				if item.cat == cats[cat][sub_cat]:
					var leaf: TreeItem = tree.create_item(b2)
					leaf.set_text(0, item.title)
					var status = 0
					if g.circuits.keys().has(key):
						status = g.circuits[key].status
					leaf.set_custom_color(0, g.STATUS_COLORS[status])
					leaf.set_metadata(0, key)


func _on_Tree_gui_input(event):
	if event is InputEventMouseMotion:
		$Bar.rect_position = Vector2(2, get_y(event.position.y))
		$Bar.rect_size = Vector2(rect_size.x - 12, 17)


func get_y(y):
	var step = 22
	return floor(y / step) * step + 7


func _on_Tree_mouse_entered():
	$Bar.show()


func _on_Tree_item_selected():
	var id = tree.get_selected().get_metadata(0)
	if id:
		emit_signal("tree_item_selected", id)
		print(id)


func _on_Tree_mouse_exited():
	$Bar.hide()
