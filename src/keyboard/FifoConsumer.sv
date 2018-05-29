`include "Datatype.svh"

module FifoConsumer(
    input                   clk,
    input                   rst,
    input                   uartBusy,
    input                   fifoEmpty,
    input   UartFifoData_t  fifoOutData,
    output                  fifoReadRequest,
    output                  uartStartSend,
    output  UartData_t      uartDataToSend
    );


    typedef enum logic[4:0] {
        STATE_INIT,
        STATE_READ_FIFO,
        STATE_SEND_UART_[0:7],
        STATE_WAIT_UART_[1:7]
    } FifoConsumerState_t;
    

    FifoConsumerState_t currentState, nextState;

    UartFifoData_t fifoData;

    always_ff @(posedge clk or posedge rst) begin
        if  (rst) begin
            currentState <= STATE_INIT;
        end else begin
            currentState <= nextState;
            if (currentState == STATE_READ_FIFO) begin
                fifoData <= fifoOutData;
            end
        end
    end

    always_comb begin
        nextState = STATE_INIT;
        fifoReadRequest = 0;
        uartStartSend = 0;
        uartDataToSend = 0;
        unique case (currentState)
            STATE_INIT: begin
                if (!fifoEmpty) begin
                    fifoReadRequest = 1;
                    nextState = STATE_READ_FIFO;
                end
            end

            STATE_READ_FIFO: begin
`define JUMP_TO_STAT(x) x: nextState = STATE_SEND_UART_``x;
                unique case (fifoOutData.length)
                    `JUMP_TO_STAT(1)
                    `JUMP_TO_STAT(2)
                    `JUMP_TO_STAT(3)
                    `JUMP_TO_STAT(4)
                    `JUMP_TO_STAT(5)
                    `JUMP_TO_STAT(6)
                    `JUMP_TO_STAT(7)
                endcase
`undef JUMP_TO_STAT
            end

`define STATE_UART(x, y) \
            STATE_SEND_UART_``x: begin \
                nextState = STATE_WAIT_UART_``x; \
                uartStartSend = 1; \
                uartDataToSend = fifoData.char``x; \
            end \
                \
            STATE_WAIT_UART_``x: begin \
                nextState = STATE_WAIT_UART_``x; \
                if (!uartBusy) begin \
                    nextState = STATE_SEND_UART_``y; \
                end \
            end

            `STATE_UART(7, 6)
            `STATE_UART(6, 5)
            `STATE_UART(5, 4)
            `STATE_UART(4, 3)
            `STATE_UART(3, 2)
            `STATE_UART(2, 1)
            `STATE_UART(1, 0)

`undef STATE_UART

            default: nextState = STATE_INIT;

        endcase
    end

endmodule