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
     
    
    // reset signals
    logic rst_n;
    assign rst_n = ~rst;


    // constants
    parameter CLOCK_FREQUNCY = 48000000;   // default clock frequency is 48 MHz
    parameter BAUD_RATE = 115200;           // default baud rate of UART


    // debug probe
    logic [127:0] debug;

    assign debug[7:0] = scan_code;
    assign debug[15:8] = ascii_code;

    Probe debugProbe(
		.probe(debug),
		.source(0)
    );
    

    // segments test
    LedDecoder decoder_1(.hex(4'h2), .segments(segment1));
    LedDecoder decoder_2(.hex(4'h3), .segments(segment2));
     
    
	// keyboard test
	logic [7:0] scan_code, ascii_code;
	logic scan_code_ready;
	logic letter_case;
	
	
	// instantiate keyboard scan code circuit
	Ps2StateMachine kb_unit(
        .clk,
        .reset(rst),
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
    logic         uartReady;
    logic [7:0]   uartDataReceived;
    logic         uartStartSend;
    logic [7:0]   uartDataToSend;
    logic         uartBusy;

    always_ff @(posedge clk) begin
        uartStartSend <= scan_code_ready;
        uartDataToSend <= ascii_code;
    end

    async_transmitter #(
        .ClkFrequency(CLOCK_FREQUNCY),
        .Baud(BAUD_RATE)
    ) uartTransmitter(
        .clk, // input
        .TxD_start(uartStartSend), // input
		.TxD_data(uartDataToSend), // input
        .TxD(uartTx), // output
        .TxD_busy(uartBusy) // output
    );

    async_receiver #(
        .ClkFrequency(CLOCK_FREQUNCY),
        .Baud(BAUD_RATE)
    ) uartReceiver(
        .clk, // input
        .RxD(uartRx), // input
        .RxD_data_ready(uartReady), // output
        .RxD_data(uartDataReceived) // output
    );


	// VT100 parser module
	VT100Parser vt100Parser(
		.clk,
		.rst(rst_n),
		.dataReady(uartReady),
		.data(uartDataReceived),
		// .cursorPosition(???),
	);


    // Phase-locked loops to generate clocks of different frequencies
    logic clk25M, clk50M, clk100M, clk10M, clk20M;
    logic rstPll, rstPll_n;
    assign rstPll_n = ~rstPll;

    TopPll divider25M(
        .areset(rst),
        .inclk0(clk),
        .c0(clk25M),
        .c1(clk50M),
        .c2(clk100M),
        .c3(clk10M),
        .c4(clk20M),
        .locked(rstPll)
    );


    // Text RAM module
    TextRamRequest_t textRamRequestParser, textRamRequestRenderer;
    TextRamResult_t textRamResultParser, textRamResultRenderer;

    TextRam textRam(
        .aclr_a(rst),
        .aclr_b(rstPll),
        .address_a(textRamRequestParser.address),
        .address_b(textRamRequestRenderer.address),
        .clock_a(clk),
        .clock_b(clk25M),
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
        .clk(clk25M),
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
        .clock(clk25M),
        .q(fontRomData)
    );


    // Renderer module
    TextRenderer renderer(
        .clk(clk25M),
        .rst(rstPll),
        .paintDone,
        .ramRequest(rendererRequest),
        .ramResult(rendererResult),
        .vgaBaseAddress,
        .textRamRequest(textRamRequestRenderer),
        .textRamResult(textRamResultRenderer),
        .fontRomAddress,
        .fontRomData,
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
