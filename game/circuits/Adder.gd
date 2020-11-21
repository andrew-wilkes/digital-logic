extends Control

# Input patterns
# left to right digits equate with top to bottom pins
# vout index obtained from LSB left evaluation of the vin value 0,0,1 = 4
var vin = [
	[0,0,0],
	[1,0,0],
	[0,1,0],
	[0,0,1],
	[1,1,0],
	[1,0,1],
	[0,1,1],
	[1,1,1]
]

var vout = [
	[0,0],
	[1,0],
	[1,0],
	[0,1],
	[1,0],
	[0,1],
	[0,1],
	[1,1]
]

export(String, MULTILINE) var info = "" 
