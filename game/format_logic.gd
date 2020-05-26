extends RichTextLabel

func _ready():
	bbcode_text = bbcode_text.replace("@", "[code]%s[/code]" % char(197))
	bbcode_text = bbcode_text.replace("*", "[code]%s[/code]" % char(215))
	bbcode_text = bbcode_text.replace("[u]", "[u][i]")
	bbcode_text = bbcode_text.replace("[/u]", "[/i][/u]")
