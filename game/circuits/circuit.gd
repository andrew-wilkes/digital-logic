extends Control

export var title = ""
# left to right digits equate with top to bottom pins
# vout index obtained from LSB left evaluation of the vin value 0,0,1 = 4
export(Array, Array, int) var vin

export(Array, Array, int) var vout
