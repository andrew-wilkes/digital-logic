tool

extends PopupPanel

export(String, MULTILINE) var note = "A @ B C * D" setget set_note_text, get_note_text
export(String, MULTILINE) var hint = "A @ B C * D" setget set_hint_text, get_hint_text

export var nt: String
export var ht: String

func play_anim():
	$Anim.play("FadeIn")


func get_note_text():
	return nt


func get_hint_text():
	return ht


func _on_OKButton_button_down():
	hide()


func show_notes():
	$VBox/M/Notes.visible = true
	$VBox/M/Hint.visible = false


func show_hint():
	$VBox/M/Notes.visible = false
	$VBox/M/Hint.visible = true


func set_note_text(txt):
	if Engine.editor_hint:
		nt = txt
		$VBox/M/Notes.bbcode_text = format_text(txt)


func set_hint_text(txt):
	if Engine.editor_hint:
		ht = txt
		$VBox/M/Hint.bbcode_text = format_text(txt)


func format_text(txt):
	# Cause the monospace font to be used
	# But we set this font to the symbol font
	txt = txt.replace("@", "[code]%s[/code]" % char(197))
	txt = txt.replace("*", "[code]%s[/code]" % char(215))
	return txt


func _on_Solution_button_down():
	show_hint()
	$VBox/HBox/Solution.disabled = true


func _on_Info_popup_hide():
	$VBox/HBox/Solution.disabled = false
	show_notes()
