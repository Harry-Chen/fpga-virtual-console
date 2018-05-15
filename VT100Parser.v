module vt100_parser(
	input clk,
	input data_ready,
	input [7:0] data,
	output reg [Width * Height * 8 - 1:0] text,
	output reg [Width * Height * 4 - 1:0] color,
	output reg [15:0] cursor_pos,
	output reg [3:0] cursor_status
);

parameter Width = 80;
parameter Height = 24;

always @(posedge clk)
begin
end

endmodule
