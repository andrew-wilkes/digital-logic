extends Label

func _ready():
	if get_parent().name == "root":
		rect_position = Vector2(100, 100)
	set_bg_size(rect_size)
	$Anim.play("Fade")

func set_bg_size(size):
	$BG.rect_size = Vector2(size.y + size.x, size.y * 2)
	$BG.rect_position = -Vector2(size.y / 2, size.y / 2)


func _on_Anim_animation_finished(_anim_name):
	queue_free()
