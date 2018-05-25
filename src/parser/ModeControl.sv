`include "DataType.svh"
`define MIN(a, b) (((a) < (b)) ? (a) : (b))
`define MAX(a, b) (((a) < (b)) ? (b) : (a))

module ModeControl(
	input                clk, rst,
	input                commandReady,
	input  CommandsType  commandType,
	input  Param_t       param,
	output TermMode_t    termMode
);

wire [7:0] Pt, Pb;
assign Pt = (param.Pn1 == 8'd0) ? 8'd0 : param.Pn1 - 8'd1;  // top margin 
assign Pb = (param.Pn2 == 8'd0) ? 8'd0 : param.Pn2 - 8'd1;  // bottom margin

always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		termMode.charset            <= 2'b0;
		termMode.scroll_top         <= 8'b0;
		termMode.scroll_bottom      <= `CONSOLE_LINES - 1;
		termMode.origin_mode        <= 1'b0;
		termMode.auto_wrap          <= 1'b1;
		termMode.replace_mode       <= 1'b0;
		termMode.line_feed          <= 1'b1;
		termMode.cursor_blinking    <= 1'b1;
		termMode.cursor_visibility  <= 1'b1;
	end else if(commandReady) begin
		case(commandType)
			DECSTBM:
			begin
				termMode.scroll_top <= Pt;
				termMode.scroll_bottom <= `MIN(Pb, `CONSOLE_COLUMNS - 1);
			end
		endcase
	end
end

endmodule 
