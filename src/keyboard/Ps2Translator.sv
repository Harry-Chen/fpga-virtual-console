`include "DataType.svh"
module Ps2Translator(
    input                   clk,
    input                   rst,
    input                   ps2Clk,
    input                   ps2Data,
    input                   fifoFull,
    output                  fifoWriteRequest,
    output  UartFifoData_t  fifoInData
    );

    logic scancodeDone;
    UartData_t scancode;

    localparam  BREAK = 8'hf0,
                LEFT_SHIFT = 8'h12,
                LEFT_CONTROL = 8'h14;

    typedef enum logic[7:0] {
        STATE_NORMAL, STATE_SHIFT, STATE_BREAK_IN_SHIFT, STATE_CONTROL, STATE_BREAK_IN_CONTROL, STATE_BREAK,
        STATE_SPECIAL_CHAR, STATE_SPECIAL_BREAK, STATE_CONTROL_SPECIAL_CHAR, STATE_CONTROL_SPECIAL_BREAK,
        STATE_SEND_SINGLE_CHAR, STATE_SEND_ARROWS, STATE_SEND_CTRL_ARROWS
        
    } Ps2TranslatorState_t;

    Ps2TranslatorState_t currentState, nextState;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            currentState <= STATE_NORMAL;
        end else begin
            currentState <= nextState;
        end
    end

    Ps2Receiver receiver(
        .clk,
        .reset(rst),
        .rx_en(1'b1),
        .ps2d(ps2Data),
        .ps2c(ps2Clock),
        .rx_done_tick(scancodeDone),
        .rx_data(scancode)
    );




endmodule