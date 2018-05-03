module FpgaVirtualConsole(
    // general signals
    input               clk,
    input               rst,
    input       [7:0]   buttons,
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
    output  reg [47:0]  segments,   // eight 7-segmented displays
    output  reg [15:0]  leds        // 16 leds
    );


    // constants
    parameter CLOCK_FREQUNCY = 100000000;   // default clock frequency is 100 MHz
    parameter BAUD_RATE = 115200;           // default baud rate of UART


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