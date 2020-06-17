extends MarginContainer

signal tree_item_selected(id)

var tree : Tree
var item_script

func _ready():
	item_script = load("res://panels/item.gd")
	tree = $Tree
	tree.connect("cell_selected", self, "tree_item_selected")
	#populate(tt.categories, tt.data)


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
					var leaf = tree.create_item(b2)
					leaf.set_text(0, item.title)
					var status = 0
					if g.circuits.keys().has(key):
						status = g.circuits[key].status
					leaf.set_custom_color(0, g.STATUS_COLORS[status])
					leaf.set_script(item_script)
					leaf.id = key


func tree_item_selected():
	var item = tree.get_selected()
	if "id" in item:
		emit_signal("tree_item_selected", item.id)
