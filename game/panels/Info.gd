tool

extends PopupPanel

export(String, MULTILINE) var note = "A @ B C * D" setget set_text

func _on_OKButton_button_down():
	hide()


func set_text(txt):
	$VBox/M/Notes.bbcode_text = format_text(txt)


func format_text(txt):
	# Cause the monospace font to be used
	# But we set this font to the symbol font
	txt = txt.replace("@", "[code]%s[/code]" % char(197))
	txt = txt.replace("*", "[code]%s[/code]" % char(215))
	return txt
