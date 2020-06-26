extends WindowDialog

signal item_selected(id)

func open(items):
	for item in items:
		$sc/ItemList.add_item(item)
	$Bar.hide()
	popup_centered()


func _on_ItemList_item_selected(index):
	hide()
	emit_signal("item_selected", index)


func _on_ItemList_gui_input(event):
	if event is InputEventMouseMotion:
		$Bar.rect_position = Vector2(2, get_y(event.position.y))
		$Bar.rect_size = Vector2(rect_size.x - 21, 17)


func get_y(y):
	var step = 24
	var dy = $sc.get_v_scroll()
	return floor(y / step) * step + 5 - dy + step * floor(dy / step)


func _on_sc_mouse_entered():
	$Bar.show()


func _on_sc_mouse_exited():
	$Bar.hide()
