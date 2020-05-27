extends AcceptDialog

signal test_button_down

func _ready():
	var b = Button.new()
	b.text = "Test"
	b.size_flags_horizontal = 3 # Fill + Expand
	b.connect("button_down", self, "b_pressed")
	var n = get_child(2)
	n.get_child(2).queue_free()
	n.get_child(1).size_flags_horizontal = 3
	n.get_child(0).queue_free()
	n.add_child(b)


func b_pressed():
	emit_signal("test_button_down")
