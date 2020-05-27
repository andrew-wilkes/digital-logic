extends Node

var data = {
	"3to8dec":
	{
		title = "Three-to-eight Decoder",
		inputs = ["A2","A1","A0"],
		outputs = ["Y0","Y1","Y2","Y3","Y4","Y5","Y6","Y7"],
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
	"fulladder":
	{
		title = "Full Adder",
		inputs = ["A","B","Cin"],
		outputs = ["Sum","Cout"],
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
	}
}
