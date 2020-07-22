extends Part

enum { CLK, IE, OE, DI, MI }
enum { DO, MO }

var sv = 0

export var title = ""

# DI is the input bus value
# DO is the output bus value
# MO is the master FF value out
# MI is the master FF value in

func _ready():
	$Title.update_title(title)
	$Title.connect("updated", self, "update_title")
	set_hex()


func update_title(txt):
	title = txt


func update_output(_pin, _state):
	match _pin.id:
		CLK:
			if !_state: # Capture the state of the Master flip flop
				set_slave(outputs[MO])
		MI:
			outputs[MO] = _state
		OE:
			if _state:
				outputs[DO] = sv
				bus_state_changed(DO, sv)
	if inputs[CLK] and inputs[IE]:
		set_output(MO, inputs[DI])
	set_hex()


func set_slave(v):
	sv = v
	if inputs[OE]:
		set_output(DO, v)


func set_output(_id, v):
	if outputs[_id] != v:
		outputs[_id] = v
		bus_state_changed(_id, v)


func set_hex():
	g.set_hex_text($V1, inputs[DI])
	g.set_hex_text($V2, outputs[MO])
	g.set_hex_text($V3, outputs[DO])
	g.set_hex_text($V4, sv)
