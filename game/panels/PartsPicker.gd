extends Control

signal picked(node)

const V_MARGIN = 28

func _ready():
	var pos = Vector2(64, -V_MARGIN)
	var files = g.get_files("res://parts", "tscn")
	files.sort()
	for file in files:
		var node = load("res://parts/" + file).instance()
		$Panel.add_child(node)
		pos.y += node.v_spacing
		node.position = pos
		node.connect("picked", self, "picked")
		node.highlight_pin = false
	var r_size = Vector2(130, pos.y + V_MARGIN)
	rect_min_size = r_size + Vector2(10, 0)
	$Panel.rect_size = r_size


func picked(node):
	emit_signal("picked", node.duplicate())
