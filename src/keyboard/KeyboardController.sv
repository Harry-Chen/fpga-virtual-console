`include "DataType.svh"

module KeyboardController(
    input               clk,
    input               rst,
    input   Ps2Signal_t ps2,
    output              uartTx
    );

    parameter ClkFrequency = 100_000_000;

    logic fifoReadRequest, fifoWriteRequest;
    logic fifoEmpty, fifoFull;
    UartFifoData_t fifoInData, fifoOutData;
    
    UartTxFifo fifo (
        .aclr(rst),
        .clock(clk),
        .data(fifoInData),
        .rdreq(fifoReadRequest),
        .wrreq(fifoWriteRequest),
        .empty(fifoEmpty),
        .full(fifoFull),
        .q(fifoOutData)
    );


    // PS2 keyboard
    logic scancodeDone;
    Scancode_t scancode;

    Ps2Receiver receiver(
        .clk,
        .reset(rst),
        .rx_en(1'b1),
        .ps2d(ps2.data),
        .ps2c(ps2.clk),
        .rx_done_tick(scancodeDone),
        .rx_data(scancode)
    );

    Ps2Translator translator(
        .clk,
        .rst,
        .scancodeDone,
        .scancode,
        .fifoFull,
        .fifoWriteRequest,
        .fifoInData
    );


    // UART module
    logic         uartStartSend;
    UartData_t    uartDataToSend;
    logic         uartBusy;

    FifoConsumer fifoConsumer(
        .clk,
        .rst,
        .uartBusy,
        .uartStartSend,
        .uartDataToSend,
        .fifoReadRequest,
        .fifoEmpty,
        .fifoOutData
    );


    AsyncUartTransmitter #(
        .ClkFrequency(ClkFrequency),
        .Baud(`BAUD_RATE)
    ) uartTransmitter(
        .clk,
        .TxD_start(uartStartSend),
		.TxD_data(uartDataToSend),
        .TxD(uartTx),
        .TxD_busy(uartBusy)
    );

endmodule