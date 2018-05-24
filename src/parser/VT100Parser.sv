`include "DataType.svh"

module VT100Parser(
	input                   clk, rst,
	input                   dataReady,
	input  [7:0]            data,
	input  TextRamResult_t  ramRes,
	output TextRamRequest_t ramReq,
	output Cursor_t         cursorInfo,
	output [31:0]           debug
);

Terminal_t term;
Param_t param;
Scrolling_t scrolling;

wire commandReady;
CommandsType commandType;

assign cursorInfo = term.cursor;

assign debug[31:24] = commandType;
assign debug[15:8] = term.cursor.x;
assign debug[7:0] = term.cursor.y;

// commands parser
CommandsParser cmd_parser(
	.clk,
	.rst,
	.data,
	.dataReady,
	.commandReady,
	.commandType,
	.param,
	.debug(debug[23:16])
);

// dispatch commands
CursorControl cursor_control(
	.clk,
	.rst,
	.commandReady,
	.commandType,
	.param,
	.term,
	.cursor(term.cursor),
	.scrolling
);

TextControl text_control(
	.clk,
	.rst,
	.commandReady,
	.commandType,
	.term,
	.param,
	.i_scrolling(scrolling),
	.ramRes,
	.ramReq
);

endmodule
