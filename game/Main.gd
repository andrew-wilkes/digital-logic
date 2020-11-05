extends CenterContainer

var wsize

func _ready():
	get_tree().get_root().connect("size_changed", self, "size_changed")
	size_changed()


func _on_Numbers_button_down():
	return get_tree().change_scene("res://Numbers.tscn")


func _on_Gates_button_down():
	return get_tree().change_scene("res://Gates.tscn")


func _on_Circuits_button_down():
	return get_tree().change_scene("res://Circuits.tscn")


func _on_Projects_button_down():
	return get_tree().change_scene("res://Systems.tscn")


func size_changed():
	wsize = get_viewport_rect().size
	$VBox/Info.text = "Panel size: %d %d" % [wsize.x, wsize.y]
	
	# iPhone 5 320 x 568
	# iPhone 6/6S iPhone 6/6S


func _on_Button_button_down():
	OS.set_window_size(wsize * 0.8)
