`include "DataType.svh"
`define MIN(a, b) (((a) < (b)) ? (a) : (b))
`define MAX(a, b) (((a) < (b)) ? (b) : (a))

module AttribControl(
	input                clk, rst,
	input                commandReady,
	input  CommandsType  commandType,
	input  Param_t       param,
	output TermAttrib_t  termAttrib
);

wire [7:0] Pt, Pb;
assign Pt = (param.Pn1 == 8'd0) ? 8'd0 : param.Pn1 - 8'd1;  // top margin 
assign Pb = (param.Pn2 == 8'd0) ? 8'd0 : param.Pn2 - 8'd1;  // bottom margin

always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		termAttrib.charset       <= 2'b0;
		termAttrib.scroll_top    <= 8'b0;
		termAttrib.scroll_bottom <= `CONSOLE_LINES - 1;
	end else if(commandReady) begin
		case(commandType)
			DECSTBM:
			begin
				termAttrib.scroll_top    <= Pt;
				termAttrib.scroll_bottom <= `MIN(Pb, `CONSOLE_COLUMNS - 1);
			end
		endcase
	end
end

endmodule
