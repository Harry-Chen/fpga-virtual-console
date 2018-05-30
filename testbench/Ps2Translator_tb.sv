`include "DataType.svh"
`timescale 1ns/1ps
module Ps2Translator_tb();

    reg clk = 0;
    Scancode_t scancode;
    reg fifoWriteRequest;
    UartFifoData_t fifoInData;
    

    Ps2Translator translator(
        .clk,
        .rst(0),
        .fifoFull(0),
        .scancodeDone(1),
        .scancode,
        .fifoWriteRequest,
        .fifoInData
        );

    always #20 clk = ~clk;

    initial begin

        // Escape
        @(negedge clk);
        scancode = 8'h76;

        @(negedge clk);
        scancode = 8'h76;

        @(negedge clk);
        scancode = 8'hF0;
        @(negedge clk);
        scancode = 8'h76;


        // Up Arrow
        @(negedge clk);
        scancode = 8'hE0;
        @(negedge clk);
        scancode = 8'h75;

        @(negedge clk);
        scancode = 8'hE0;
        @(negedge clk);
        scancode = 8'h75;

        @(negedge clk);
        scancode = 8'hF0;
        @(negedge clk);
        scancode = 8'hE0;
        @(negedge clk);
        scancode = 8'h75;


        // F12
        @(negedge clk);
        scancode = 8'h07;

        @(negedge clk);
        scancode = 8'h07;

        @(negedge clk);
        scancode = 8'hF0;
        @(negedge clk);
        scancode = 8'h07;


        // Ctrl + Up Arrow
        @(negedge clk);
        scancode = 8'h14;

        @(negedge clk);
        scancode = 8'h14;

        @(negedge clk);
        scancode = 8'hE0;
        @(negedge clk);
        scancode = 8'h75;

        @(negedge clk);
        scancode = 8'hE0;
        @(negedge clk);
        scancode = 8'h75;

        @(negedge clk);
        scancode = 8'hE0;
        @(negedge clk);
        scancode = 8'hF0;
        @(negedge clk);
        scancode = 8'h75;

        @(negedge clk);
        scancode = 8'hF0;
        @(negedge clk);
        scancode = 8'h14;

        // Shift + A
        @(negedge clk);
        scancode = 8'h59;

        @(negedge clk);
        scancode = 8'h59;

        @(negedge clk);
        scancode = 8'h1C;

        @(negedge clk);
        scancode = 8'h1C;

        @(negedge clk);
        scancode = 8'hF0;
        @(negedge clk);
        scancode = 8'h1C;

        @(negedge clk);
        scancode = 8'hF0;
        @(negedge clk);
        scancode = 8'h59;

    end

endmodule