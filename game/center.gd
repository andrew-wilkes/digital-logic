extends Container


func _ready():
	return get_tree().get_root().connect("size_changed", self, "size_changed")


func size_changed():
	self.rect_position = (get_viewport_rect().size - self.rect_size) / 2
