extends Node

var data

func _ready():
	pass


func add_property_to_data(key, value):
	load_data()
	for item in data.values():
		item[key] = value
		print(item.title, item[key])
	save_data()


func change_property_of_data(key):
	load_data()
	for item in data.values():
		for p in item.parts:
			p[key] = [p[key]]
			print(p[key])
	save_data()


func remove_item(key):
	load_data()
	if data.erase(key):
		print("Done")
		save_data()
	else:
		print("Key not found: ", key)



func load_data():
	data = g.load_file(g.PART_FILE_PATH + "data.json")


func save_data():
	g.save_file(g.PART_FILE_PATH + "data.json", data)
