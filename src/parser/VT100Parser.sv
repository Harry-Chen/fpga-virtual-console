`include "DataType.svh"

module VT100Parser(
	input                   clk, rst,
	input                   dataReady,
	input  [7:0]            data,
	input  TextRamResult_t  ramRes,
	output TextRamRequest_t ramReq,
	output Cursor_t         cursorInfo,
	output [70:0]           debug
);

Terminal_t term;
Param_t param;
Scrolling_t scrolling;

wire commandReady, scrollReady;
CommandsType commandType;

assign cursorInfo = term.cursor;

assign debug[70:62] = term.graphics.fg;
assign debug[61:53] = term.graphics.bg;
assign debug[51:44] = term.attrib.scroll_top;
assign debug[43:36] = term.attrib.scroll_bottom;
assign debug[31:24] = commandType;
assign debug[15:8] = term.cursor.x;
assign debug[7:0] = term.cursor.y;

logic blinkStatus, blinkReset;

BlinkGenerator #(
	.ClkFrequency(100_000_000)
) blink(
	.clk(clk),
	.sync_reset(blinkReset),
	.status(blinkStatus)
);

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
	.blinkStatus,
	.blinkReset,
	.cursor(term.cursor),
	.o_scrolling(scrolling),
	.scrollReady,
	.debug(debug[52])
);

TextControl text_control(
	.clk,
	.rst,
	.commandReady,
	.commandType,
	.term,
	.param,
	.scrollReady,
	.i_scrolling(scrolling),
	.ramRes,
	.ramReq,
	.prevData(term.prev_data),
	.debug(debug[35:32])
);

ModeControl mode_control(
	.clk,
	.rst,
	.commandReady,
	.commandType,
	.param,
	.termMode(term.mode)
);

AttribControl attrib_control(
	.clk,
	.rst,
	.commandReady,
	.commandType,
	.param,
	.termAttrib(term.attrib)
);

GraphicsControl graphics_control(
	.clk,
	.rst,
	.commandReady,
	.commandType,
	.Pns(param.Pns),
	.graphics(term.graphics)
);

endmodule
