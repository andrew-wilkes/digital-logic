extends Node

const COLOR_HIGH = Color.red
const COLOR_LOW = Color.blue
const COLOR_ACTIVE = Color.green
const COLOR_UNDEFINED = Color.white
const GRID_SIZE = 10
const PART_FILE_PATH = "res://parts/lib/"
const UNSTABLE_THRESHOLD = 20

var wire = null

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


func save_file(fn, data):
	var file = File.new()
	file.open(fn, File.WRITE)
	file.store_string(to_json(data))
	file.close()


func load_file(fn):
	var file = File.new()
	if file.file_exists(fn):
		file.open(fn, File.READ)
		return parse_json(file.get_as_text())
