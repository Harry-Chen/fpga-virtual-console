`include "Datatype.svh"

module FifoConsumer(
    input               clk,
    input               rst,
    input               uartBusy,
    input               fifoEmpty,
    input   UartData_t  fifoOutData,
    output              fifoReadRequest,
    output              uartStartSend,
    output  UartData_t  uartDataToSend
    );

    typedef enum logic[1:0] {
        STATE_INIT, STATE_READ_FIFO, STATE_WAIT_UART
    } FifoConsumerState_t;

    FifoConsumerState_t currentState, nextState;

    always_ff @(posedge clk or posedge rst) begin
        if  (rst) begin
            currentState <= STATE_INIT;
        end else begin
            currentState <= nextState;
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
                nextState = STATE_WAIT_UART;
                uartStartSend = 1;
                uartDataToSend = fifoOutData;
            end

            STATE_WAIT_UART: begin
                nextState = STATE_WAIT_UART;
                if (!uartBusy) begin
                    nextState = STATE_INIT;
                end
            end

            default: nextState = STATE_INIT;

        endcase
    end

endmodule