extends Control

export var TEST = false
export var GUTTER_OFFSET = 40

var _state = 0

func _ready():
	if TEST:
		$Timer.start()


func _on_Timer_timeout():
	match _state:
		0:
			$Timer.wait_time = 2
		1: 
			notify("Hello")
		2:
			notify("The quick brown fox jumps over the lazy dog.")
		3:
			notify("Bye")
	_state += 1


func _on_Anim_animation_finished(_anim_name):
	$PopupPanel.hide()


func notify(_text):
	$PopupPanel/Label.text = _text
	$PopupPanel.popup_centered()
	$PopupPanel.set_as_minsize()
	$PopupPanel.popup_centered() # Realign to center after resizing
	$PopupPanel.rect_position.y = get_viewport_rect().size.y - GUTTER_OFFSET
	$Anim.play("Fade")
