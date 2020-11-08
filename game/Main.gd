extends Control

var wsize

func _ready():
	get_tree().get_root().connect("size_changed", self, "size_changed")
	size_changed()

func size_changed():
	wsize = get_viewport_rect().size
	$VBox/Info.text = "%d x %d" % [wsize.x, wsize.y]
