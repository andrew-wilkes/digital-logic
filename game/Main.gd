extends CenterContainer

func _ready():
	get_tree().get_root().connect("size_changed", self, "size_changed")


func _on_Numbers_button_down():
	return get_tree().change_scene("res://Numbers.tscn")


func _on_Gates_button_down():
	return get_tree().change_scene("res://Gates.tscn")


func _on_Circuits_button_down():
	return get_tree().change_scene("res://Circuits.tscn")


func _on_Projects_button_down():
	return get_tree().change_scene("res://Systems.tscn")


func size_changed():
	print("New panel size: ", get_viewport_rect().size)
	# iPhone 5 320 x 568
	# iPhone 6/6S iPhone 6/6S
