extends PanelContainer

export(String, MULTILINE) var text setget set_text


func set_text(txt):
	$Margin/Label.text = txt
