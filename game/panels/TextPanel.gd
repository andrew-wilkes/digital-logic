extends PanelContainer

export(String, MULTILINE) var text setget set_text

func _ready():
	set_text($Margin/Label.bbcode_text)


func set_text(txt):
	$Margin/Label.bbcode_text = g.format_text(txt)
