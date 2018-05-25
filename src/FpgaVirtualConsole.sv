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

    assign debug[7:0] = scan_code;
    assign debug[15:8] = ascii_code;
	assign debug[102:32] = vt100_debug;

    Probe debugProbe(
		.probe(debug),
		.source(0)
    );
    

    // segments test
    LedDecoder decoder_1(.hex(vt100_debug[19:16]), .segments(segment1));
    LedDecoder decoder_2(.hex(vt100_debug[23:20]), .segments(segment2));


    // Phase-locked loops to generate clocks of different frequencies
    logic clk25M, clk50M, clk100M, clk10M, clk20M;
    logic rstPll;

    TopPll topPll(
        .areset(rst),
        .inclk0(clk),
        .c0(clk25M),
        .c1(clk50M),
        .c2(clk100M),
        .c3(clk10M),
        .c4(clk20M),
        .locked(~rstPll)
    );
     
    
	// keyboard test
	logic [7:0] scan_code, ascii_code;
	logic scan_code_ready;
	logic letter_case;
	
	// instantiate keyboard scan code circuit
	Ps2StateMachine kb_unit(
        .clk(clk100M),
        .reset(rstPll),
        .ps2d(ps2Data),
        .ps2c(ps2Clk),
        .scan_code,
        .scan_code_ready,
        .letter_case_out(letter_case)
    );
					
	// instantiate key-to-ascii code conversion circuit
	ScanCodeToAscii k2a_unit(
        .letter_case,
        .scan_code,
        .ascii_code
    );


    // UART module
    logic         uartStartSend;
    logic [7:0]   uartDataToSend;
    logic         uartBusy;

    assign uartStartSend = scan_code_ready;
    assign uartDataToSend = ascii_code;

    AsyncUartTransmitter #(
        .ClkFrequency(100_000_000),
        .Baud(`BAUD_RATE)
    ) uartTransmitter(
        .clk(clk100M),
        .TxD_start(uartStartSend),
		.TxD_data(uartDataToSend),
        .TxD(uartTx),
        .TxD_busy(uartBusy)
    );

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


	// VT100 parser module
    logic [70:0] vt100_debug;
    Cursor_t cursor;
    logic blinkStatus;

    BlinkGenerator #(
        .ClkFrequency(100_000_000)
    ) blink(
        .clk(clk100M),
        .status(blinkStatus)
    );

	VT100Parser vt100Parser(
        .clk(clk100M),
        .rst(rstPll),
        .dataReady(uartReady),
        .data(uartDataReceived),
        .ramRes(textRamResultParser),
        .ramReq(textRamRequestParser),
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


    // Sram controller module
    SramRequest_t vgaRequest, rendererRequest;
    SramResult_t vgaResult, rendererResult;
    logic paintDone;
    SramAddress_t vgaBaseAddress;
    
    SramController sramController(
        .clk(clk50M),
        .rst(rstPll),
        .sramInterface,
        .sramData,
        .vgaRequest,
        .vgaResult,
        .rendererRequest,
        .rendererResult
    );


    // Font ROM module
    FontRomData_t fontRomData;
    FontRomAddress_t fontRomAddress;

    FontRom fontRom(
        .aclr(rstPll),
        .address(fontRomAddress),
        .clock(clk50M),
        .q(fontRomData)
    );


    // Renderer module
    TextRenderer renderer(
        .clk(clk50M),
        .rst(rstPll),
        .paintDone,
        .ramRequest(rendererRequest),
        .ramResult(rendererResult),
        .vgaBaseAddress,
        .textRamRequest(textRamRequestRenderer),
        .textRamResult(textRamResultRenderer),
        .fontRomAddress,
        .fontRomData,
        .cursor,
        .blinkStatus,
        .nowRendering(debug[31:16])
    );


    // VGA module
    VgaDisplayAdapter display(
        .clk(clk25M),
        .rst(rstPll),
        .baseAddress(vgaBaseAddress),
        .ramRequest(vgaRequest),
        .ramResult(vgaResult),
        .vga,
        .paintDone
    );


endmodule
