extends Control

func _ready():
	if OS.get_name() == "Windows":
		var screen_size = OS.get_screen_size()
		var window_size = OS.get_window_size()
		OS.set_window_position(Vector2((screen_size.x - window_size.x) * 0.5, 0))
		OS.set_window_size(Vector2(window_size.x, screen_size.y - 75))
	$Anim.play("Intro")
