extends Node

var categories = {
	"Combinational Logic": 
		{
			"Decoders": "dec",
			"Encoders": "enc",
			"Multiplexers": "mult",
			"Demultiplexers": "demult",
			"Mathematical": "math"
		},
	"Sequential Logic":
		{
			"SR Flip-flop": "sr",
			"JK Flip-flop": "jk",
			"D Flip-flop": "d",
			"Shift Register": "shift",
			"Counters": "count"
		}
}

var data = {
	"3to8dec":
	{
		title = "Three-to-eight Decoder",
		cat = "dec",
		inputs = ["A2","A1","A0"],
		iparts = [],
		outputs = ["Y0","Y1","Y2","Y3","Y4","Y5","Y6","Y7"],
		oparts = [],
		values = [
			[0,0,0,1,0,0,0,0,0,0,0],
			[0,0,1,0,1,0,0,0,0,0,0],
			[0,1,0,0,0,1,0,0,0,0,0],
			[0,1,1,0,0,0,1,0,0,0,0],
			[1,0,0,0,0,0,0,1,0,0,0],
			[1,0,1,0,0,0,0,0,1,0,0],
			[1,1,0,0,0,0,0,0,0,1,0],
			[1,1,1,0,0,0,0,0,0,0,1]
		],
		desc = "This is an example of a decoder. It takes a 3-bit binary input and decodes it to one of eight possible outputs.",
		hint = "To decode the inputs, we can combine AND gates and NOT gates.\n\nFor example: [i]Y5 = A2 * [u]A1[/u] * A0[/i]"
		
	},
	"7-segment":
	{
		title = "7-Segment Decoder",
		cat = "dec",
		inputs = ["I3", "I2","I1","I0"],
		iparts = ["4-bit_Switch"],
		outputs = ["a","b","c","d","e","f","g"],
		oparts = ["7-Segment_Display"],
		values = [
			[0,0,0,0,1,1,1,1,1,1,0], #0
			[0,0,0,1,0,1,1,0,0,0,0], #1
			[0,0,1,0,1,1,0,1,1,0,1], #2
			[0,0,1,1,1,1,1,1,0,0,1], #3
			[0,1,0,0,0,1,1,0,0,1,1], #4
			[0,1,0,1,1,0,1,1,0,1,1], #5
			[0,1,1,0,1,0,1,1,1,1,1], #6
			[0,1,1,1,1,1,1,0,0,0,0], #7
			[1,0,0,0,1,1,1,1,1,1,1], #8
			[1,0,0,1,1,1,1,1,0,1,1]  #9
		],
		desc = "The 7-segment decoder is used to select the 7 segments of a seven-segment display. Only input values from 0-9 need to be decoded.",
		hint = "Combine AND, NAND, OR, and NOT gates."
	},
	"2-1multiplexer":
	{
		title = "Two-to-one Multiplexer",
		cat = "mult",
		inputs = ["A","B","Select"],
		iparts = [],
		outputs = ["Out"],
		oparts = [],
		values = [
			[0,0,0,0],
			[0,0,1,0],
			[0,1,0,0],
			[0,1,1,1],
			[1,0,0,1],
			[1,0,1,0],
			[1,1,0,1],
			[1,1,1,1]
		],
		desc = "A multiplexer is used to select one of it's inputs to pass to the output like a switch.",
		hint = "[i]Out = [u]Select[/u] * A + Select * B[/i]"
	},
	"fulladder":
	{
		title = "Full Adder",
		cat = "math",
		inputs = ["A","B","Cin"],
		iparts = [],
		outputs = ["Sum","Cout"],
		oparts = [],
		values = [
			[0,0,0,0,0],
			[0,0,1,1,0],
			[0,1,0,1,0],
			[0,1,1,0,1],
			[1,0,0,1,0],
			[1,0,1,0,1],
			[1,1,0,0,1],
			[1,1,1,1,1]
		],
		desc = "A full adder adds together a carry input, A, and B to give two outputs: sum and carry out.",
		hint = "We have 3 bits to add together producing numbers in a range 0 to 3.\n\nIn binary: 00 to 11 with the least significant bit the sum, and the most significant bit the carry out.\n\nTo get the sum we can use exclusive OR: [i]A @ B @ Cin[/i]\n\nThe carry out is high if at least two of the inputs are high, so:\n[i]Cout = A * B + A * Cin + B * Cin[/i]"
	},
	"srflipflop":
	{
		title = "SR Flip Flop",
		cat = "sr",
		inputs = ["S", "R"],
		iparts = [],
		outputs = ["+Q", "-Q"],
		oparts = [],
		values = [
			[1,0,1,0],
			[0,0,1,0],
			[0,1,0,1],
			[0,0,0,1],
			[1,0,1,0],
			[0,0,1,0]
		],
		desc = "An SR flip flop remembers the state as long as both R and S are low. Pulsing R high resets the state (+Q low), and pulsing S high sets the state (+Q high).",
		hint = "Use two NOR gates."
	},
	"srflipflopenable":
	{
		title = "SR Flip Flop with enable",
		cat = "sr",
		inputs = ["E", "S", "R"],
		iparts = [],
		outputs = ["+Q", "-Q"],
		oparts = [],
		values = [
			[0,0,0,1,0],
			[0,0,1,1,0],
			[0,0,0,1,0],
			[0,1,0,1,0],
			[0,0,0,1,0],
			[1,1,0,1,0],
			[1,0,0,1,0],
			[1,0,1,0,1],
			[1,0,0,0,1],
			[1,1,0,1,0],
			[1,0,0,1,0]
		],
		desc = "We can add an enable input (E) to an SR flip-flop so that it can only change state when E is high.",
		hint = "Add AND gates to the inputs."
	},
	"dlatch":
	{
		title = "D Latch",
		cat = "d",
		inputs = ["E", "D"],
		iparts = [],
		outputs = ["+Q", "-Q"],
		oparts = [],
		values = [
			[1,0,0,1],
			[0,0,0,1],
			[0,1,0,1],
			[1,1,1,0],
			[0,1,1,0],
			[0,0,1,0]
		],
		desc = "We can set [i]R = [u]S[/u][/i] since R and S should never be high at the same time. So we replace S and R with a data input (D) and set the E input low when we want to remember the input value.",
		hint = "Simply add a NOT gate to the input of an SR flip flop."
	}
}
