extends Control

var count = 0.0
var time = 0.0
var rounds = 0
var idx = 0
var state = IDLE
var output = 0
var start_time

enum { IDLE, PLAYING, PAUSED } # States
enum { START, STOP, ONE, ZERO, TIMEOUT } # Events
enum { AND, NAND, OR, NOR, XOR, NOT }
enum { CROSS, TICK, Q }

const NUM_GATES = 6
const MAX_TIME = 24 * 3600 * 1000

func _ready():
	g.set_column_size($VBox)
	$VBox/HBox/OneButton.hide()
	$VBox/HBox/ZeroButton.hide()


func sm(event):
	match state:
		IDLE:
			match event:
				START:
					$VBox/HBox/OneButton.show()
					$VBox/HBox/ZeroButton.show()
					$VBox/HBox/Start.hide()
					$VBox/HBox/Stop.show()
					$VBox/M2/Score/Accuracy.text = ""
					$VBox/M2/Score/Speed.text = ""
					count = 0.0
					time = 0.0
					rounds = 0
					idx = 0
					set_next_gate()
					state = PLAYING
		PLAYING:
			match event:
				STOP:
					$VBox/HBox/OneButton.hide()
					$VBox/HBox/ZeroButton.hide()
					$VBox/HBox/Start.show()
					$VBox/HBox/Stop.hide()
					$VBox/Gate.reset()
					state = IDLE
				ONE:
					$VBox/Gate.set_output(int(output))
					idx += 1
					if output:
						correct()
						add_to_time()
					else:
						wrong()
					update_score()
					$Timer.start()
					state = PAUSED # Wait for TIMEOUT
				ZERO:
					$VBox/Gate.set_output(int(output))
					idx += 1
					if !output:
						correct()
						add_to_time()
					else:
						wrong()
					update_score()
					$Timer.start()
					state = PAUSED
		PAUSED:
			if event == TIMEOUT:
				$VBox/Gate.set_output(2) # Revert to white
				set_next_gate()
				state = PLAYING


func correct():
	count += 1
	$VBox/Gate.set_result(TICK)


func wrong():
	$VBox/Gate.set_result(CROSS)


func add_to_time():
	time += OS.get_system_time_msecs() - start_time


func set_next_gate():
	if idx == NUM_GATES:
		rounds += 1
		idx = 0
	$VBox/Gate.set_gate(idx)
	var inputs = $VBox/Gate.set_inputs()
	output = get_output(inputs)
	start_time = OS.get_system_time_msecs()


func get_output(v):
	match idx:
		AND:
			return v[0] & v[1]
		NAND:
			return !(v[0] & v[1])
		OR:
			return v[0] | v[1]
		NOR:
			return !(v[0] | v[1])
		XOR:
			return v[0] ^ v[1]
		NOT:
			return !v[0]


func test_score():
	count = 1
	idx = 1
	rounds = 0
	time = MAX_TIME
	update_score()


func update_score():
	var accuracy = int(100 * count / (idx + rounds * NUM_GATES))
	$VBox/M2/Score/Accuracy.text = "%d%% correct" % accuracy
	if count > 0:
		var speed = time / count # How many correct / time
		$VBox/M2/Score/Speed.text = "%dms" % speed


func _on_ZeroButton_button_down():
	sm(ZERO)


func _on_OneButton_button_down():
	sm(ONE)


func _on_Start_button_down():
	sm(START)


func _on_Stop_button_down():
	sm(STOP)


func _on_Timer_timeout():
	sm(TIMEOUT)
