`include "DataType.sv"

module ActionCursor(
	input       clk, rst,
	input       commandReady,
	input       commandType,
	input  [7:0] i_cursor_x, i_cursor_y,
	input  [7:0] Pn1, Pn2,
	output [7:0] o_cursor_x, o_cursor_y
);

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
				o_cursor_x <= Pn1 - 8'd1;
				o_cursor_y <= Pn2 - 8'd1;
			end
		endcase
	end
end

endmodule
