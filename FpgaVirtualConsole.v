module FpgaVirtualConsole(
    // general signals
    input               clk,
    input               rst,
    input       [3:0]   buttons,
    // PS/2 receiver
    input               ps2Clk,
    input               ps2Data,
    // uart transceiver
    input               uartRx,
    output  reg         uartTx,
    // vga output
    output  reg         vgaHSync,
    output  reg         vgaVSync,
    output  reg [2:0]   vgaRed,
    output  reg [2:0]   vgaGreen,
    output  reg [2:0]   vgaBlue,
    // debug output
    output  reg [55:0]  segmentDiaplays   // eight 7-segmented displays
    );


    // constants
    parameter CLOCK_FREQUNCY = 100000000;   // default clock frequency is 100 MHz
    parameter BAUD_RATE = 115200;           // default baud rate of UART


    // 7-segmented displays
    reg     [3:0]   segmentDisplayHex[0:7]; // eight hex 
    wire    [55:0]  segmentDiaplaySignal;

    always @(posedge clk) begin
        segmentDiaplays <= segmentDiaplaySignal;
    end

    LedDecoder decoder_1(.hex(segmentDisplayHex[7]), .segments(segmentDiaplaySignal[55:49]));
    LedDecoder decoder_2(.hex(segmentDisplayHex[6]), .segments(segmentDiaplaySignal[48:42]));
    LedDecoder decoder_3(.hex(segmentDisplayHex[5]), .segments(segmentDiaplaySignal[41:35]));
    LedDecoder decoder_4(.hex(segmentDisplayHex[4]), .segments(segmentDiaplaySignal[34:28]));
    LedDecoder decoder_5(.hex(segmentDisplayHex[3]), .segments(segmentDiaplaySignal[27:21]));
    LedDecoder decoder_6(.hex(segmentDisplayHex[2]), .segments(segmentDiaplaySignal[20:14]));
    LedDecoder decoder_7(.hex(segmentDisplayHex[1]), .segments(segmentDiaplaySignal[13:7]));
    //LedDecoder decoder_8(.hex(segmentDisplayHex[0]), .segments(segmentDiaplaySignal[6:0]));
	 
	 
	// keyboard test
	wire [7:0] scan_code, ascii_code;
	wire scan_code_ready;
	wire letter_case;
	
	assign segmentDiaplaySignal[6:0] = ascii_code;
	
	// instantiate keyboard scan code circuit
	Ps2StateMachine kb_unit (.clk(clk), .reset(rst), .ps2d(ps2Data), .ps2c(ps2Clk),
			 .scan_code(scan_code), .scan_code_ready(scan_code_ready), .letter_case_out(letter_case));
					
	// instantiate key-to-ascii code conversion circuit
	ScanCodeToAscii k2a_unit (.letter_case(letter_case), .scan_code(scan_code), .ascii_code(ascii_code));

    // UART module
    reg         uartReady;
    reg [7:0]   uartDataReceived;
    reg         uartStartSend;
    reg [7:0]   uartDataToSend;
    reg         uartBusy;

    wire        uartTxSignal;
    wire        uartBusySignal;
    wire        uartReadySignal;
    wire [7:0]  uartDataSignal;

    always @(posedge clk) begin
        uartTx <= uartTxSignal;
        uartBusy <= uartBusySignal;
        uartReady <= uartReadySignal;
        uartDataReceived <= uartDataSignal;
        uartStartSend <= scan_code_ready;
        uartDataToSend <= ascii_code;
    end

    async_transmitter #(
        .ClkFrequency(CLOCK_FREQUNCY),
        .Baud(BAUD_RATE)
    ) uartTransmitter(
        .clk(clk), // input
        .TxD_start(uartStartSend), // input
		.TxD_data(uartDataToSend), // input
        .TxD(uartTxSignal), // output
        .TxD_busy(uartBusySignal) // output
    );

    async_receiver #(
        .ClkFrequency(CLOCK_FREQUNCY),
        .Baud(BAUD_RATE)
    ) uartReceiver(
        .clk(clk), // input
        .RxD(uartRx), // input
        .RxD_data_ready(uartReadySignal), // output
        .RxD_data(uartDataSignal) // output
    );


    // VGA module
    wire         vgaHSyncSignal;
    wire         vgaVSyncSignal;
    wire [2:0]   vgaRedSignal;
    wire [2:0]   vgaGreenSignal;
    wire [2:0]   vgaBlueSignal;

    always @(posedge clk) begin
        vgaHSync <= vgaHSyncSignal;
        vgaVSync <= vgaVSyncSignal;
        vgaRed <= vgaRedSignal;
        vgaGreen <= vgaGreenSignal;
        vgaBlue <= vgaBlueSignal;
    end

    VgaDisplayAdapter_640_480 #(
        .ClkFrequency(CLOCK_FREQUNCY)
    ) display(
        .CLK(clk),
        .RST_BTN(rst),
        .VGA_HS_O(vgaHSyncSignal),
        .VGA_VS_O(vgaVSyncSignal),
        .VGA_R(vgaRedSignal),
        .VGA_G(vgaGreenSignal),
        .VGA_B(vgaBlueSignal)
    );


endmodule