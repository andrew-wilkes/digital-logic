extends Node2D

onready var s = $Segments

export(Color, RGB) var color
export(Color, RGBA) var off_color

var map = [
	0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,0x77,0x7c,0x39,0x5e,0x79,0x71
]

var count = 0

func _ready():
	if get_parent().name == "root":
		set_segment(7, 0)
		$Timer.start()


func set_segment(i: int, b: bool):
		if b:
			s.get_child(i).modulate = color
		else:
			s.get_child(i).modulate = off_color


func set_segments(x):
	var n = 1
	for i in 7:
		set_segment(i, n & x)
		n = n << 1


func _on_Timer_timeout():
	set_segments(map[count])
	count += 1
	if count > 0xf:
		count = 0
