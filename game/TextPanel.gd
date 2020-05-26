extends PanelContainer

export(String, MULTILINE) var text setget set_text

func _ready():
	set_text($Margin/Label.bbcode_text)


func set_text(txt):
	txt = txt.replace("@", "[code]%s[/code]" % char(197))
	txt = txt.replace("*", "[code]%s[/code]" % char(215))
	$Margin/Label.bbcode_text = "[_]" + txt
