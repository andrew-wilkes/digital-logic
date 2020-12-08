extends Control

func _ready():
	g.set_column_size($VBox)
	$Anim.play("Intro")
