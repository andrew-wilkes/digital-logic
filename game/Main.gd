extends Control

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
	#var font_size = 50
	#if wsize.x < 720 or wsize.y < 900:
	#font_size *= 2
	#	$VBox.rect_scale = Vector2(0.5, 0.5)
	#$VBox/Title.get_font("font").size = font_size
	$VBox/Info.text = "%d x %d" % [wsize.x, wsize.y]
	# iPhone 5 320 x 568
	# iPhone 6/6S iPhone 6/6S
