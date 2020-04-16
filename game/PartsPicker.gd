extends Control

signal picked(node)

const YSTEP = 64 * 1.2

func _ready():
	var pos = Vector2(64, 42)
	var files = g.get_files("parts", "tscn")
	for file in files:
		var node = load("res://parts/" + file).instance()
		node.position = pos
		pos.y += YSTEP
		$Panel.add_child(node)
		node.connect("picked", self, "picked")
	$Panel.rect_size = Vector2(120, pos.y)


func picked(node):
	emit_signal("picked", node.duplicate())
