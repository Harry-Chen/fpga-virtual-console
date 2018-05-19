`include "DataType.svh"

module ActionCursor(
	input       clk, rst,
	input       commandReady,
	input       commandType,
	input  [7:0] i_cursor_x, i_cursor_y,
	input  [7:0] Pn1, Pn2,
	output [7:0] o_cursor_x, o_cursor_y
);

wire [7:0] Pn, Pl, Pc;

assign Pl = (Pn1 == 8'd0) ? 0 : Pn1 - 8'd1;  // line number
assign Pc = (Pn2 == 8'd0) ? 0 : Pn2 - 8'd1;  // column number
assign Pn = Pl;   // number 

always @(posedge clk or negedge rst)
begin
	if(~rst)
	begin
		o_cursor_x <= 8'd0;
		o_cursor_y <= 8'd0;
	end
	else if(commandReady)
	begin
		unique case(commandType)
			CUP:  // Cursor Position
			begin
				o_cursor_x <= Pl;
				o_cursor_y <= Pc;
			end
			CUF:  // Cursor Forward 
				o_cursor_y <= (i_cursor_y + Pn >= `CONSOLE_COLUMNS) ? `CONSOLE_COLUMNS - 1 : i_cursor_y + Pn;
			CUB:  // Cursor Backward
				o_cursor_y <= (i_cursor_y < Pn) ? 8'd0 : i_cursor_y - Pn;
			CUD:  // Cursor Down
				o_cursor_x <= (i_cursor_x + Pn >= `CONSOLE_LINES) ? `CONSOLE_LINES - 1 : i_cursor_x + Pn;
			CUU:  // Cursor Up
				o_cursor_x <= (i_cursor_x < Pn) ? 8'd0 : i_cursor_x - Pn;
			IND:  // Index
				o_cursor_x <= (i_cursor_x + 8'd1 >= `CONSOLE_LINES) ? `CONSOLE_LINES - 1 : i_cursor_x + 8'd1;
			RI:  // Reverse Index
				o_cursor_x <= (i_cursor_x == 8'd0) ? 8'd0 : i_cursor_x - 8'd1;
			NEL:  // Next Line
			begin
				o_cursor_x <= (i_cursor_x + 8'd1 >= `CONSOLE_LINES) ? `CONSOLE_LINES - 1 : i_cursor_x + 8'd1;
				o_cursor_y <= 8'd0;
			end
			default:
			begin
				o_cursor_x <= i_cursor_x;
				o_cursor_y <= i_cursor_y;
			end
		endcase
	end
end

endmodule
