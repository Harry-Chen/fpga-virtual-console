`include  "DataType.svh"
`timescale 1ns/1ps
module VgaDisplayAdapter_tb();

    reg clk = 0;
    reg rst = 0;
    VgaSignal_t vga;
    SramRequest_t ramRequest;
    SramResult_t ramResult;

    VgaDisplayAdapter adapter(
        .clk,
        .rst,
        .baseAddress(0),
        .ramResult,
        .ramRequest,
        .vga
    );

    always #5 clk = ~clk;

    initial begin
        #5 rst = 1;
        #5 rst = 0;
    end

endmodule