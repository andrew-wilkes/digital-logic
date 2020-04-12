extends Node2D

class_name Gate

var inputs = []
var output: Vector2

func _ready():
	# get connection points
	var n = get_child_count()
	for i in range(1, n - 2):
		inputs.append(get_child(i).position)
	output = get_child(n - 1).position
