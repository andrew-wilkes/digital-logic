tool
extends RichTextEffect

class_name Overline

# Syntax: [^][/^]

# Define the tag name.
var bbcode = "_"

func _ready():
	resource_name = "Overline"


func _process_custom_fx(char_fx):
	char_fx.offset = Vector2(0, 16)
	return true
