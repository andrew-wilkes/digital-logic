extends Node

const COLOR_HIGH = Color.red
const COLOR_LOW = Color.blue
const COLOR_BUS = Color(0.0, 0.3, 1.0)
const COLOR_ACTIVE = Color.green
const COLOR_UNDEFINED = Color.white
const GRID_SIZE = 10
const PART_FILE_PATH = "user://circuits/"
const STATE_FILE_PATH = "user://state.json"
const UNSTABLE_THRESHOLD = 4
const STATUS_COLORS = [Color.white, Color.orange, Color.red, Color.green, Color.yellow]
const DEBUG = false

var wire = null
var circuits = {}
var param
var debug_id = 0
var state = {
	"ci": [# Lists of collapsed tree item references
		[],
		[],
		[],
		[],
		[],
		[]
	]
}


func _ready():
	load_state()
	var dir = Directory.new()
	var path = PART_FILE_PATH.rstrip("/")
	if dir.open(path) != OK:
		dir.make_dir(path)


func get_debug_id():
	debug_id += 1
	return debug_id


func load_state():
	var data = load_file(STATE_FILE_PATH)
	if data:
		state = data


func save_state():
	save_file(STATE_FILE_PATH, state)


func load_circuits():
	var data = load_file(PART_FILE_PATH + "data.json")
	if data:
		circuits = data


func delete_file(path, fn):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.remove(fn)


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


func get_state_color(_state):
	if _state:
		return g.COLOR_HIGH
	else:
		return g.COLOR_LOW


func format_text(txt):
	txt = txt.replace("@", "[code]%s[/code]" % char(197))
	txt = txt.replace("*", "[code]%s[/code]" % char(215))
	return "[_]" + txt


func decode_inputs(inputs):
	var x = 0
	for i in range(inputs.size() - 1, -1, -1):
		x = x << 1
		if inputs[i]:
			x += 1
	return x
