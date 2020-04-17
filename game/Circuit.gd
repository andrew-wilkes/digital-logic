extends Node2D

var part_moving = false
var part

func _ready():
	# warning-ignore:return_value_discarded
	$PartsPicker.connect("picked", self, "part_picked")


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseMotion && part_moving:
		part.position = (event.position / g.GRID_SIZE).round() * g.GRID_SIZE


func part_picked(node):
	set_part_moving(node)
	part.active = true
	part.connect("picked", self, "set_part_moving")
	part.connect("dropped", self, "part_dropped")
	part.connect("doubleclick", self, "part_delete")
	add_child(part)	


func part_dropped():
	part_moving = false


func set_part_moving(node):
	part = node
	part_moving = true


func part_delete():
	part.queue_free()
