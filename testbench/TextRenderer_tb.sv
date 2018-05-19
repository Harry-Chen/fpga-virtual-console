`include "DataType.sv"
`timescale 1ns/1ps
module TextRenderer_tb();

reg clk = 0;
reg rst = 0;

TextRamRequest_t textRamRequest;
TextRamResult_t textRamResult;

logic [15:0] nowRendering;

TextRenderer renderer(
    .clk,
    .rst,
    .paintDone(1),
    .ramResult(~64'h0),
    .textRamRequest,
    .textRamResult,
    .fontRomData(~192'h0),
    .nowRendering
);

TextRam ram(
    .aclr_b(0),
    .address_b(textRamRequest.address),
    .clock_b(clk),
    .data_b(textRamRequest.data),
    .wren_b(0),
    .q_b(textRamResult)
);

always #20 clk=~clk;

initial begin
    @(negedge clk);
    rst = 1;
end

endmodule
