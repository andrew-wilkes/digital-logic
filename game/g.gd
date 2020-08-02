extends Node

const COLOR_HIGH = Color.red
const COLOR_LOW = Color.blue
const COLOR_BUS = Color(0.0, 0.3, 1.0)
const COLOR_ACTIVE = Color.green
const COLOR_UNDEFINED = Color.white
const GRID_SIZE = 10
const PART_FILE_PATH = "user://circuits/"
const STATE_FILE_PATH = "user://state.json"
const SRC_FILE_PATH = "user://src/"
const UNSTABLE_THRESHOLD = 4
const STATUS_COLORS = [Color.white, Color.orange, Color.red, Color.green, Color.yellow]
const DEBUG = false

var page = 0
var pc = 0
var max_page = 0

var clicked_item = false
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
var mem = []
var src = ""
var popup_size: Vector2

func _ready():
	popup_size = OS.get_screen_size() / 2
	load_state()
	var dir = Directory.new()
	check_dir(dir, PART_FILE_PATH)
	check_dir(dir, SRC_FILE_PATH)


func check_dir(dir, path):
	path = path.rstrip("/")
	if !dir.dir_exists(path):
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


func save_file(fn, data, encode = true):
	if encode:
		data = to_json(data)
	var file = File.new()
	file.open(fn, File.WRITE)
	file.store_string(data)
	file.close()


func load_file(fn, decode = true):
	var file = File.new()
	if file.file_exists(fn):
		file.open(fn, File.READ)
		var data = file.get_as_text()
		if decode:
			data = parse_json(data)
		return data


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


func set_hex_text(label: Label, value: int):
	label.text = "%02X" % value
