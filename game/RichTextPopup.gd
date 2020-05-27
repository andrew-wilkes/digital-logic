extends WindowDialog

var text = "" setget set_text

func set_text(txt):
	$Text.bbcode_text = g.format_text(txt)
	popup_centered()
