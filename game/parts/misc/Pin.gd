extends Area2D

class_name Pin

var parent_part
var is_output = false
var wires = []
var id = 0
var updated = 0
var debug_id = 0
var color
var color_a
export(bool) var vert = false
export(bool) var is_bus = false

func _ready():
	set_color()
	if g.DEBUG:
		debug_id = g.get_debug_id()
		$Label.show()
		$Label.text = str(debug_id)


func state_changed(_state = "?"):
	if g.DEBUG:
		print("%3d\t%s" % [debug_id, _state])
	updated += 1
	return updated > g.UNSTABLE_THRESHOLD


func reset_state_changed():
	updated = 0


func show_it():
	$Sprite.show()


func hide_it():
	$Sprite.hide()


func _on_Pin_mouse_entered():
	modulate = color


func _on_Pin_mouse_exited():
	modulate = color_a


func set_color():
	if is_bus:
		color = g.COLOR_BUS
	else:
		color = g.COLOR_ACTIVE
	color_a = color
	color_a.a = 0.5
	modulate = color_a
