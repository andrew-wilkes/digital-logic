extends Node2D

var picked = false
var part

func _ready():
	# warning-ignore:return_value_discarded
	$PartsPicker.connect("picked", self, "part_picked")


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseMotion && picked:
		part.position = (event.position / g.GRID_SIZE).round() * g.GRID_SIZE


func part_picked(node):
	part = node
	part.connect("dropped", self, "part_dropped")
	part.active = true
	add_child(part)	
	picked = true


func part_dropped():
	picked = false
