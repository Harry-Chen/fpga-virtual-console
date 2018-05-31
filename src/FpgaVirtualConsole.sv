`include "DataType.svh"
module FpgaVirtualConsole(
    // general signals
    input                              clk,
    input                              rst,
    input  [4:0]                       buttons,
    // PS/2 receiver
    input                              ps2Clk,
    input                              ps2Data,
    // uart transceiver
    input                              uartRx,
    output reg                         uartTx,
    // vga output
    output VgaSignal_t                 vga,
    // sram read/write
    output SramInterface_t             sramInterface,
    inout  [`SRAM_DATA_WIDTH - 1:0]    sramData,
    // debug output
    output reg [7:0]                   segment1,
    output reg [7:0]                   segment2,
    output reg [15:0]                  led
    );

    

    // debug probe
    logic [127:0] debug;
    logic [70:0]  vt100_debug;
	assign debug[102:32] = vt100_debug;

    Probe debugProbe(
		.probe(debug),
		.source(0)
    );
    

    // segments test
    LedDecoder decoder_1(.hex(vt100_debug[19:16]), .segments(segment1));
    LedDecoder decoder_2(.hex(vt100_debug[23:20]), .segments(segment2));


    // Phase-locked loops to generate clocks of different frequencies
    logic clk50M, clk100M;
    logic rstPll, rstPll_n;
	assign rstPll = ~rstPll_n;

    TopPll topPll(
        .areset(rst),
        .inclk0(clk),
        .c0(clk50M),
        .c1(clk100M),
        .locked(rstPll_n)
    );


    // Keyboard to uart
    KeyboardController #(
        .ClkFrequency(100_000_000)
    ) keyboardController(
        .clk(clk100M),
        .rst(rstPll),
        .ps2Clk,
        .ps2Data,
        .uartTx
    );
					

    VideoController VideoController(
        .clk100M,
        .clk50M,
        .rst(rstPll)
        .uartRx,
        .vga,
        .sramInterface,
        .sramData,
        .debug(vt100_debug)
    );



endmodule
