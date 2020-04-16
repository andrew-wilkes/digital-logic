extends Control

signal picked(node)

const V_MARGIN = 28

func _ready():
	var pos = Vector2(64, -V_MARGIN)
	var files = g.get_files("parts", "tscn")
	files.sort()
	for file in files:
		var node = load("res://parts/" + file).instance()
		pos.y += node.v_spacing
		node.position = pos
		$Panel.add_child(node)
		node.connect("picked", self, "picked")
	$Panel.rect_size = Vector2(130, pos.y + V_MARGIN)


func picked(node):
	emit_signal("picked", node.duplicate())
