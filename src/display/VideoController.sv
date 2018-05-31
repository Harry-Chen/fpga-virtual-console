`include "DataType.svh"
module VideoController(
    input                               clk100M,
    input                               clk50M,
    input                               uartRx,
    output  VgaSignal_t                 vga,
    // sram read/write
    output  SramInterface_t             sramInterface,
    inout   [`SRAM_DATA_WIDTH - 1:0]    sramData,
    // debug
    output  logic[70:0]                 debug
    );

        // UART Receiver
    logic         uartReady;
    logic [7:0]   uartDataReceived;

    AsyncUartReceiver #(
        .ClkFrequency(100_000_000),
        .Baud(`BAUD_RATE)
    ) uartReceiver(
        .clk(clk100M),
        .RxD(uartRx),
        .RxD_data_ready(uartReady),
        .RxD_data(uartDataReceived)
    );


    // Global blink generator module
    logic blinkStatus;

    BlinkGenerator #(
        .ClkFrequency(100_000_000)
    ) blink(
        .clk(clk100M),
        .status(blinkStatus)
    );


	// VT100 parser module
    logic [70:0] vt100_debug;
    assign debug = vt100_debug;
    Cursor_t cursor;

	VT100Parser vt100Parser(
        .clk(clk100M),
        .rst(rstPll),
        .dataReady(uartReady),
        .data(uartDataReceived),
        .ramRes(textRamResultParser),
        .ramReq(textRamRequestParser),
		.blinkStatus,
        .debug(vt100_debug),
        .cursorInfo(cursor)
    );


    // Text RAM module
    TextRamRequest_t textRamRequestParser, textRamRequestRenderer;
    TextRamResult_t textRamResultParser, textRamResultRenderer;

    TextRam textRam(
        .aclr_a(rstPll),
        .aclr_b(rstPll),
        .address_a(textRamRequestParser.address),
        .address_b(textRamRequestRenderer.address),
        .clock_a(clk100M),
        .clock_b(clk50M),
        .data_a(textRamRequestParser.data),
        .data_b(textRamRequestRenderer.data),
        .wren_a(textRamRequestParser.wren),
        .wren_b(textRamRequestRenderer.wren),
        .q_a(textRamResultParser),
        .q_b(textRamResultRenderer)
    );


    // Video controller module
    DisplayController controller(
        .clk(clk50M),
        .rst(rstPll),
        .blinkStatus,
        .cursor,
        .textRamResult(textRamResultRenderer),
        .textRamRequest(textRamRequestRenderer),
        .sramInterface,
        .sramData,
        .vga
    );

endmodule