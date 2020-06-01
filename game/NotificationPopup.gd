extends Control

var state = 0

func notify(txt):
	$PopupPanel/Label.text = txt
	$PopupPanel.popup_centered()
	$PopupPanel.set_as_minsize()
	$PopupPanel.popup_centered() # Realign to center after resizing
	$Anim.play("Fade")


func _on_Timer_timeout():
	match state:
		0: 
			notify("Hello")
		1:
			$PopupPanel.hide()
			notify("Hello World Hello World Hello World")
		2:
			$PopupPanel.hide()
			notify("Bye")
	state += 1
