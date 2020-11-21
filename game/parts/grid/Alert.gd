extends PopupPanel

func show():
	popup_centered()
	$Timer.start()


func _on_Timer_timeout():
	hide()
