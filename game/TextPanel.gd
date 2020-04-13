extends PanelContainer

export(String, MULTILINE) var text

func _ready():
	$Margin/Label.text = text
