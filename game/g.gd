extends Node

const COLOR_HIGH = Color.green
const COLOR_LOW = Color.blue

func get_files(path, ext):
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				if file_name.ends_with(ext):
					files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: " + path)
	return files
