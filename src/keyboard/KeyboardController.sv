`include "DataType.svh"

module KeyboardController(
    input   clk,
    input   rst,
    input   ps2Clk,
    input   ps2Data,
    output  uartTx
    );

    parameter ClkFrequency = 100_000_000;

    logic fifoReadRequest, fifoWriteRequest;
    logic fifoEmpty, fifoFull;
    UartData_t fifoInData, fifoOutData;
    
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
    logic         uartStartSend;
    logic [7:0]   uartDataToSend;
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