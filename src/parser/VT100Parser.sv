`include "DataType.svh"

module VT100Parser(
	input         clk, rst,
	input         dataReady,
	input  [7:0]  data,
	output [15:0] cursorPosition,
	output [41:0] debug
);

// cursor position, starts from 0
reg [7:0] cursor_x, cursor_y;

// set flatten cursor position 
assign cursorPosition = cursor_x * `CONSOLE_COLUMNS + cursor_y;

// input parameters
reg [7:0] Pn1, Pn2, Pchar;

wire commandReady;
CommandsType commandType;

reg [7:0] status;

// DEBUG INFO BEGIN
LedDecoder decoder_x1(.hex(cursor_x[7:4]), .segments(debug[41:35]));
LedDecoder decoder_x2(.hex(cursor_x[3:0]), .segments(debug[34:28]));
LedDecoder decoder_y1(.hex(cursor_y[7:4]), .segments(debug[27:21]));
LedDecoder decoder_y2(.hex(cursor_y[3:0]), .segments(debug[20:14]));
LedDecoder decoder_c1(.hex(status[7:4]), .segments(debug[13:7]));
LedDecoder decoder_c2(.hex(status[3:0]), .segments(debug[6:0]));
// DEBUG INFO END

// commands parser
CommandsParser cmd_parser(
	.clk(clk),
	.rst(rst),
	.data(data),
	.dataReady(dataReady),
	.commandReady(commandReady),
	.commandType(commandType),
	.Pn1(Pn1),
	.Pn2(Pn2),
	.Pchar(Pchar),
	.debug(status)
);

// dispatch commands
ActionCursor action_cursor(
	.clk(clk),
	.rst(rst),
	.commandReady(commandReady),
	.commandType(commandType),
	.Pn1(Pn1),
	.Pn2(Pn2),
	.o_cursor_x(cursor_x),
	.o_cursor_y(cursor_y),
	.i_cursor_x(cursor_x),
	.i_cursor_y(cursor_y)
);

endmodule
