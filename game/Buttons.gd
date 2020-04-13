extends HBoxContainer


func disable_button(idx):
	get_child(idx).visible = false


func _on_Home_button_down():
	get_tree().change_scene("res://Main.tscn")


func _on_Numbers_button_down():
	get_tree().change_scene("res://Numbers.tscn")


func _on_Gates_button_down():
	get_tree().change_scene("res://Gates.tscn")


func _on_Circuits_button_down():
	get_tree().change_scene("res://Circuits.tscn")


func _on_Projects_button_down():
	get_tree().change_scene("res://Projects.tscn")
