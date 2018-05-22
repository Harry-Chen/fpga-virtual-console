`include "DataType.svh"
`define MOVE_NEXT_LINE \
	o_cursor.x <= (i_cursor.x + 8'd1 >= `CONSOLE_LINES) ? `CONSOLE_LINES - 1 : i_cursor.x + 8'd1;

module CursorControl(
	input               clk, rst,
	input               commandReady,
	input  CommandsType commandType,
	input  Param_t      param,
	input  Terminal_t   term,
	output Cursor_t     o_cursor
);

wire [7:0] Pn, Pl, Pc;
Cursor_t i_cursor;

assign i_cursor = term.cursor;
assign Pl = (param.Pn1 == 8'd0) ? 8'd0 : param.Pn1 - 8'd1;  // line number
assign Pc = (param.Pn2 == 8'd0) ? 8'd0 : param.Pn2 - 8'd1;  // column number
assign Pn = (param.Pn1 == 8'd0) ? 8'd1 : param.Pn1;         // number 

always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		o_cursor.x <= 8'd0;
		o_cursor.y <= 8'd0;
	end else if(commandReady) begin
		unique case(commandType)
			CUP:  // Cursor Position
			begin
				o_cursor.x <= Pl;
				o_cursor.y <= Pc;
			end
			CUF:  // Cursor Forward 
				o_cursor.y <= (i_cursor.y + Pn >= `CONSOLE_COLUMNS) ? `CONSOLE_COLUMNS - 1 : i_cursor.y + Pn;
			CUB:  // Cursor Backward
				o_cursor.y <= (i_cursor.y < Pn) ? 8'd0 : i_cursor.y - Pn;
			CUD:  // Cursor Down
				o_cursor.x <= (i_cursor.x + Pn >= `CONSOLE_LINES) ? `CONSOLE_LINES - 1 : i_cursor.x + Pn;
			CUU:  // Cursor Up
				o_cursor.x <= (i_cursor.x < Pn) ? 8'd0 : i_cursor.x - Pn;
			IND:  // Index
				`MOVE_NEXT_LINE
			RI:  // Reverse Index
				o_cursor.x <= (i_cursor.x == 8'd0) ? 8'd0 : i_cursor.x - 8'd1;
			NEL:  // Next Line
			begin
				`MOVE_NEXT_LINE
				o_cursor.y <= 8'd0;
			end
			INPUT:
				unique case(param.Pchar)
				8'o12,8'o13,8'o14:  // LF, VT, FF
					`MOVE_NEXT_LINE
				8'o15: // CR
					o_cursor.y <= 8'd0;
				8'o10: // BS, TODO: not sure if y == 0
					o_cursor.y <= (i_cursor.y == 8'd0) ? 8'd0 : i_cursor.y - 8'd1;
				8'o11: // HT
					// TODO
					o_cursor.y <= i_cursor.y; //placeholder
				default:  // TODO: not sure if y + 1 == COL
					o_cursor.y <= (i_cursor.y + 8'd1 >= `CONSOLE_COLUMNS) ? `CONSOLE_COLUMNS - 1 : i_cursor.y + 8'd1;
				endcase
			default:
			begin
				o_cursor.x <= i_cursor.x;
				o_cursor.y <= i_cursor.y;
			end
		endcase
	end
end

endmodule
