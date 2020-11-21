extends Control

var vin = [
	[0,0],
	[1,0], # Reset
	[0,0],
	[0,1] # Set
]
var vout = [
	[2,2], # Remember last value
	[0,1],
	[1,0]
]

export(String, MULTILINE) var info = "SR Flip Flop" 
