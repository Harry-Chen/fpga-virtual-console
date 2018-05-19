`timescale 1ns/1ps
module FontShapeRenderer_tb();

reg clk = 0;
reg rst = 0;

FontShapeRenderer dut(
    .clk,
    .rst,
    .grid(0),
    .baseAddress(0),
    .ramResult(~64'h0)
);

always #20 clk=~clk;

initial begin
    @(negedge clk);
    rst = 1;
end

endmodule
