module FpgaVirtualConsole(
    input               clk,
    input               rst,
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
    output  reg [47:0]  segments,
    output  reg [15:0]  leds
);

reg         uartReady;
reg [7:0]   uartDataReceived;
reg         uartStartSend;
reg [7:0]   uartDataToSend;
reg         uartBusy;

wire        uartTxSignal;
wire        uartBusySignal;
wire        uartReadySignal;
wire [7:0]  uartDataSignal;

always @(posedge clk)
begin
    uartTx <= uartTxSignal;
    uartBusy <= uartBusySignal;
    uartReady <= uartReadySignal;
    uartDataReceived <= uartDataSignal;
end

async_transmitter #(
    .ClkFrequency(1000000),
    .Baud(115200)
) uartTransmitter(
    .clk(clk), // input
    .TxD_start(uartStartSend), // input
    .TxD_data(uartDataToSend), // input
    .TxD(uartTxSignal), // output
    .TxD_busy(uartBusySignal) // output
);

async_receiver #(
    .ClkFrequency(1000000),
    .Baud(115200)
) uartReceiver(
	.clk(clk), // input
	.RxD(uartRx), // input
	.RxD_data_ready(uartReadySignal), // output
	.RxD_data(uartDataSignal), // output
);

endmodule