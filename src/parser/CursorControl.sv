`include "DataType.svh"
`define MIN(a, b) (((a) < (b)) ? (a) : (b))
`define MAX(a, b) (((a) < (b)) ? (b) : (a))

module CursorControl(
	input               clk, rst,
	input               commandReady,
	input  CommandsType commandType,
	input  Param_t      param,
	input  Terminal_t   term,
	output Cursor_t     cursor,
	output              resetScrollRegion
);

// the origin of cursor is (origin_x, 0)
wire [7:0] origin_x, cursor_x_max;
assign origin_x     = term.origin_mode ? term.scroll_top : 8'd0;
assign cursor_x_max = term.scroll_bottom - origin_x;

// i_cursor and o_cursor is relative to (origin_x, 0)
Cursor_t i_cursor, o_cursor;
assign cursor.y = o_cursor.y;
assign cursor.x = origin_x + o_cursor.x;
assign i_cursor.y = term.cursor.y;
assign i_cursor.x = term.cursor.x - origin_x;

// some wires
wire [7:0] next_line;
assign next_line = `MIN(i_cursor.x + 8'd1, cursor_x_max);

// Pn is used for single parameter commands
// Pl, Pc is used for CUP command
wire [7:0] Pn, Pl, Pc;
assign Pl = (param.Pn1 == 8'd0) ? 8'd0 : param.Pn1 - 8'd1;  // line number
assign Pc = (param.Pn2 == 8'd0) ? 8'd0 : param.Pn2 - 8'd1;  // column number
assign Pn = (param.Pn1 == 8'd0) ? 8'd1 : param.Pn1;         // number 

assign resetScrollRegion = (
	commandReady &&
	(commandType == CUP) &&
	~term.origin_mode &&
	(Pl > term.scroll_bottom)
);

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
				o_cursor.x <= `MIN(Pl, term.origin_mode ? cursor_x_max : `CONSOLE_LINES - 1);
				o_cursor.y <= `MIN(Pc, `CONSOLE_COLUMNS - 1);
			end
			CUF:  // Cursor Forward 
				o_cursor.y <= `MIN(i_cursor.y + Pn, `CONSOLE_COLUMNS - 1);
			CUB:  // Cursor Backward
				o_cursor.y <= (i_cursor.y < Pn) ? 8'd0 : i_cursor.y - Pn;
			CUD:  // Cursor Down
				o_cursor.x <= `MIN(i_cursor.x + Pn, cursor_x_max);
			CUU:  // Cursor Up
				o_cursor.x <= (i_cursor.x < Pn) ? 8'd0 : i_cursor.x - Pn;
			IND:  // Index
				// TODO: SCROLL NEEDED
				o_cursor.x <= next_line;
			RI:  // Reverse Index
				// TODO: SCROLL NEEDED
				o_cursor.x <= (i_cursor.x == 8'd0) ? 8'd0 : i_cursor.x - 8'd1;
			NEL:  // Next Line
			begin
				// TODO: SCROLL NEEDED
				o_cursor.x <= next_line;
				o_cursor.y <= 8'd0;
			end
			INPUT:
				unique case(param.Pchar)
				8'o12,8'o13,8'o14:  // LF, VT, FF
				begin
					o_cursor.x <= next_line;
					o_cursor.y <= term.line_feed ? 8'd0 : o_cursor.y;
				end
				8'o15: // CR
					o_cursor.y <= 8'd0;
				8'o10: // BS, TODO: not sure if y == 0
					o_cursor.y <= (i_cursor.y == 8'd0) ? 8'd0 : i_cursor.y - 8'd1;
				8'o11: // HT
					// TODO
					o_cursor.y <= i_cursor.y; //placeholder
				default:
					if(i_cursor.y + 8'd1 < `CONSOLE_COLUMNS)
					begin
						o_cursor.y <= i_cursor.y + 8'd1;
					end else if(term.auto_wrap) begin
						// TODO: SCROLL NEEDED
						o_cursor.x <= next_line;
						o_cursor.y <= 8'd0;
					end
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
