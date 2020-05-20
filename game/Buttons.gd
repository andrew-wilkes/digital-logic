extends HBoxContainer

export(int) var page_id

func _ready():
	disable_button(page_id)


func disable_button(idx):
	get_child(idx).disabled = true


func _on_Home_button_down():
	return get_tree().change_scene("res://Main.tscn")


func _on_Numbers_button_down():
	return get_tree().change_scene("res://Numbers.tscn")


func _on_Gates_button_down():
	return get_tree().change_scene("res://Gates.tscn")


func _on_Circuits_button_down():
	return get_tree().change_scene("res://Circuits.tscn")


func _on_Projects_button_down():
	return get_tree().change_scene("res://Systems.tscn")
