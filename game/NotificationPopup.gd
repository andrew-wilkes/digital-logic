extends Control

var state = 0

func notify(txt):
	$PopupPanel/Label.text = txt
	$PopupPanel.popup_centered()
	$PopupPanel.set_as_minsize()
	$PopupPanel.popup_centered() # Realign to center after resizing
	$PopupPanel.rect_position.y = get_viewport_rect().size.y - 40
	$Anim.play("Fade")

# Check timer autostart property for testing
func _on_Timer_timeout():
	match state:
		0: 
			notify("Hello")
		1:
			notify("Hello World Hello World Hello World")
		2:
			notify("Bye")
	state += 1


func _on_Anim_animation_finished(_anim_name):
	$PopupPanel.hide()
