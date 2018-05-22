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
	.o_cursor(term.cursor)
);

TextEdit text_edit(
	.clk,
	.rst,
	.commandReady,
	.commandType,
	.term,
	.param,
	.ramRes,
	.ramReq
);

// test text input
// logic [1:0] wrs = 0;
// always @(posedge clk)
// begin
// 	case(wrs)
// 		1: begin
// 			ramReq.address <= term.cursor.x;
// 			ramReq.wren <= 0;
// 			wrs <= 2;
// 		end
// 		2: begin
// 			ramReq.data <= {ramRes[`TEXT_RAM_DATA_WIDTH - 1 -: (`CONSOLE_COLUMNS - 1) * 16], 8'd0, param.Pchar};
// 			ramReq.wren <= 1;
// 			wrs <= 3;
// 		end
// 		3: begin
// 			ramReq.wren <= 0;
// 			wrs <= 0;
// 		end
// 	endcase
// 	if(commandReady)
// 	begin
// 		if(commandType == INPUT)
// 		begin
// 			wrs <= 1;
// 		end
// 	end
// end

endmodule
